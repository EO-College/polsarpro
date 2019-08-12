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
    set base .top394
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.cpd88 {
        array set save {-height 1 -highlightcolor 1 -width 1}
    }
    set site_3_0 $base.cpd88
    namespace eval ::widgets::$site_3_0.cpd97 {
        array set save {-foreground 1 -ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd92 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd92
    namespace eval ::widgets::$site_6_0.cpd84 {
        array set save {-foreground 1 -highlightcolor 1 -image 1 -pady 1 -relief 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd98 {
        array set save {-foreground 1 -ipad 1 -text 1}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    namespace eval ::widgets::$site_5_0 {
        array set save {}
    }
    set site_5_0 $site_5_0
    namespace eval ::widgets::$site_5_0.cpd85 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -selectbackground 1 -selectforeground 1 -takefocus 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_5_0.cpd72 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd72
    namespace eval ::widgets::$site_6_0.lab73 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd91 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_6_0 $site_5_0.cpd91
    namespace eval ::widgets::$site_6_0.cpd89 {
        array set save {-_tooltip 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$base.fra55 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra55
    namespace eval ::widgets::$site_3_0.lab57 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent58 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab59 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent60 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab61 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent62 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.lab63 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.ent64 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$base.fra59 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_3_0 $base.fra59
    namespace eval ::widgets::$site_3_0.but93 {
        array set save {-_tooltip 1 -background 1 -command 1 -foreground 1 -highlightcolor 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.but24 {
        array set save {-_tooltip 1 -background 1 -command 1 -foreground 1 -highlightcolor 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd66 {
        array set save {-foreground 1 -ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd66 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd72 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd73 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd74
    namespace eval ::widgets::$site_5_0.cpd105 {
        array set save {-_tooltip 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd69 {
        array set save {}
    }
    set site_5_0 $site_4_0.cpd69
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-_tooltip 1 -background 1 -command 1 -foreground 1 -highlightcolor 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd67 {
        array set save {-foreground 1 -ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd67 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd110 {
        array set save {-height 1 -highlightcolor 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd110
    namespace eval ::widgets::$site_5_0.fra23 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_6_0 $site_5_0.fra23
    namespace eval ::widgets::$site_6_0.che24 {
        array set save {-foreground 1 -highlightcolor 1 -takefocus 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra29 {
        array set save {-height 1 -highlightcolor 1 -width 1}
    }
    set site_6_0 $site_5_0.fra29
    namespace eval ::widgets::$site_6_0.che30 {
        array set save {-foreground 1 -highlightcolor 1 -takefocus 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.but31 {
        array set save {-_tooltip 1 -background 1 -command 1 -foreground 1 -highlightcolor 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$base.cpd68 {
        array set save {-foreground 1 -ipad 1 -text 1}
    }
    set site_4_0 [$base.cpd68 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.fra90 {
        array set save {-height 1 -highlightcolor 1 -width 1}
    }
    set site_5_0 $site_4_0.fra90
    namespace eval ::widgets::$site_5_0.fra91 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_6_0 $site_5_0.fra91
    namespace eval ::widgets::$site_6_0.cpd95 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra92 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_6_0 $site_5_0.fra92
    namespace eval ::widgets::$site_6_0.but80 {
        array set save {-_tooltip 1 -command 1 -foreground 1 -highlightcolor 1 -image 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_6_0.cpd102 {
        array set save {-_tooltip 1 -background 1 -command 1 -foreground 1 -highlightcolor 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.fra93 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_6_0 $site_5_0.fra93
    namespace eval ::widgets::$site_6_0.cpd97 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -selectbackground 1 -selectforeground 1 -state 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.cpd101 {
        array set save {-height 1 -highlightcolor 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd101
    namespace eval ::widgets::$site_5_0.che24 {
        array set save {-command 1 -foreground 1 -highlightcolor 1 -takefocus 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_5_0.fra25 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_6_0 $site_5_0.fra25
    namespace eval ::widgets::$site_6_0.fra38 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_7_0 $site_6_0.fra38
    namespace eval ::widgets::$site_7_0.che29 {
        array set save {-foreground 1 -highlightcolor 1 -takefocus 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.che31 {
        array set save {-foreground 1 -highlightcolor 1 -takefocus 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_6_0.fra39 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_7_0 $site_6_0.fra39
    namespace eval ::widgets::$site_7_0.fra42 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_8_0 $site_7_0.fra42
    namespace eval ::widgets::$site_8_0.lab47 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.lab48 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.lab49 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_7_0.fra43 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_8_0 $site_7_0.fra43
    namespace eval ::widgets::$site_8_0.lab52 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.lab53 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.lab54 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$base.tit69 {
        array set save {-text 1}
    }
    set site_4_0 [$base.tit69 getframe]
    namespace eval ::widgets::$site_4_0 {
        array set save {}
    }
    set site_4_0 $site_4_0
    namespace eval ::widgets::$site_4_0.cpd70 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_5_0 $site_4_0.cpd70
    namespace eval ::widgets::$site_5_0.cpd69 {
        array set save {-foreground 1 -ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd69 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd77 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd77
    namespace eval ::widgets::$site_8_0.rad91 {
        array set save {-borderwidth 1 -command 1 -foreground 1 -highlightcolor 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.fra70 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_8_0 $site_7_0.fra70
    namespace eval ::widgets::$site_8_0.cpd71 {
        array set save {-command 1 -foreground 1 -highlightcolor 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_8_0.cpd72 {
        array set save {-_tooltip 1 -background 1 -command 1 -foreground 1 -highlightcolor 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_5_0.cpd75 {
        array set save {-foreground 1 -ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd75 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd110 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd110
    namespace eval ::widgets::$site_8_0.fra23 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1}
    }
    set site_9_0 $site_8_0.fra23
    namespace eval ::widgets::$site_9_0.cpd79 {
        array set save {-foreground 1 -highlightcolor 1 -takefocus 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd77 {
        array set save {-command 1 -foreground 1 -highlightcolor 1 -takefocus 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_5_0.cpd74 {
        array set save {-foreground 1 -ipad 1 -text 1}
    }
    set site_7_0 [$site_5_0.cpd74 getframe]
    namespace eval ::widgets::$site_7_0 {
        array set save {}
    }
    set site_7_0 $site_7_0
    namespace eval ::widgets::$site_7_0.cpd110 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd110
    namespace eval ::widgets::$site_8_0.fra23 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_9_0 $site_8_0.fra23
    namespace eval ::widgets::$site_9_0.fra74 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.fra74
    namespace eval ::widgets::$site_10_0.cpd75 {
        array set save {-borderwidth 1 -command 1 -foreground 1 -highlightcolor 1 -takefocus 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_10_0.cpd76 {
        array set save {-borderwidth 1 -command 1 -foreground 1 -highlightcolor 1 -selectcolor 1 -takefocus 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_10_0.lab77 {
        array set save {-borderwidth 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.fra77 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.fra77
    namespace eval ::widgets::$site_10_0.cpd78 {
        array set save {-foreground 1 -highlightcolor 1 -takefocus 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_10_0.cpd79 {
        array set save {-foreground 1 -highlightcolor 1 -takefocus 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.cpd71 {
        array set save {-foreground 1 -ipad 1 -relief 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd71 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.cpd110 {
        array set save {-height 1 -highlightcolor 1 -width 1}
    }
    set site_7_0 $site_6_0.cpd110
    namespace eval ::widgets::$site_7_0.fra72 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_8_0 $site_7_0.fra72
    namespace eval ::widgets::$site_8_0.cpd79 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd78 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.fra80 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -width 1}
    }
    set site_8_0 $site_7_0.fra80
    namespace eval ::widgets::$site_8_0.cpd109 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.cpd109
    namespace eval ::widgets::$site_9_0.fra96 {
        array set save {-height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.fra96
    namespace eval ::widgets::$site_10_0.cpd68 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_11_0 $site_10_0.cpd68
    namespace eval ::widgets::$site_11_0.cpd69 {
        array set save {-borderwidth 1 -command 1 -foreground 1 -highlightcolor 1 -takefocus 1 -text 1 -variable 1}
    }
    namespace eval ::widgets::$site_11_0.lab71 {
        array set save {-borderwidth 1 -text 1}
    }
    namespace eval ::widgets::$site_10_0.cpd70 {
        array set save {-_tooltip 1 -background 1 -command 1 -foreground 1 -highlightcolor 1 -padx 1 -pady 1 -takefocus 1 -text 1}
    }
    namespace eval ::widgets::$site_9_0.fra72 {
        array set save {-height 1 -relief 1 -width 1}
    }
    set site_10_0 $site_9_0.fra72
    namespace eval ::widgets::$site_10_0.cpd73 {
        array set save {-borderwidth 1 -command 1 -foreground 1 -highlightcolor 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_10_0.cpd74 {
        array set save {-borderwidth 1 -foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_10_0.cpd75 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.fra66 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.fra66
    namespace eval ::widgets::$site_9_0.cpd67 {
        array set save {-height 1 -highlightcolor 1 -width 1}
    }
    set site_10_0 $site_9_0.cpd67
    namespace eval ::widgets::$site_10_0.cpd104 {
        array set save {-borderwidth 1 -command 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_10_0.cpd90 {
        array set save {-foreground 1 -highlightcolor 1 -text 1}
    }
    namespace eval ::widgets::$site_10_0.cpd89 {
        array set save {-background 1 -disabledbackground 1 -disabledforeground 1 -foreground 1 -highlightcolor 1 -insertbackground 1 -justify 1 -selectbackground 1 -selectforeground 1 -takefocus 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_8_0.fra79 {
        array set save {-borderwidth 1 -height 1 -highlightcolor 1 -relief 1 -width 1}
    }
    set site_9_0 $site_8_0.fra79
    namespace eval ::widgets::$site_9_0.cpd80 {
        array set save {-borderwidth 1 -command 1 -foreground 1 -highlightcolor 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$base.m66 {
        array set save {-activeborderwidth 1 -borderwidth 1 -tearoff 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist {_TopLevel _vTclBalloon}
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            vTclWindow.
            vTclWindow.top394
            InitRBF
            ResetRBF
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
## Procedure:  InitRBF

proc ::InitRBF {} {
global TrainingSamplingVal TrainingSampling UnbalanceTraining OldModel NewModel
global CostVal PolyDeg RBFGamma PolyDegVar RBFGammaVar Npolar
global RBFCV Kernel 
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep
global PolarIndic PSPBackgroundColor

    set Kernel "2"
    set CostVal 100
    set RBFGamma [expr 4.*1./$Npolar]
    set RBFGammaVar [expr 4.*1./$Npolar]
    set PolyDegVar ""
    set PolyDeg "DISABLE"
    set RBFCV "0"
    set OldModel "0"
    .top394.tit69.f.cpd71.f.cpd110.fra80.cpd109.fra72.cpd74 configure -state normal
    .top394.tit69.f.cpd71.f.cpd110.fra80.cpd109.fra72.cpd75 configure -state normal
    .top394.tit69.f.cpd71.f.cpd110.fra80.cpd109.fra72.cpd75 configure -disabledbackground #FFFFFF

    .top394.tit69.f.cpd71.f.cpd110.fra80.cpd109.fra96.cpd68.lab71 configure -state normal
    .top394.tit69.f.cpd71.f.cpd110.fra80.cpd109.fra96.cpd70 configure -state disable
    .top394.tit69.f.cpd71.f.cpd110.fra80.cpd109.fra96.cpd68.cpd69 configure -state normal

    .top394.tit69.f.cpd71.f.cpd110.fra80.fra66.cpd67.cpd89 configure -state disable
    .top394.tit69.f.cpd71.f.cpd110.fra80.fra66.cpd67.cpd89 configure -disabledbackground $PSPBackgroundColor
    .top394.tit69.f.cpd71.f.cpd110.fra80.fra66.cpd67.cpd90 configure -state disable
}
#############################################################################
## Procedure:  ResetRBF

proc ::ResetRBF {} {
global TrainingSamplingVal TrainingSampling UnbalanceTraining OldModel NewModel
global CostVal PolyDeg RBFGamma PolyDegVar RBFGammaVar
global RBFCV Kernel PSPBackgroundColor
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep

    set Kernel ""
    set PolyDegVar ""
    set PolyDeg "DISABLE"
    set RBFCV "0"
    set RBFGammaVar ""
    set RBFGamma "DISABLE"
    set Log2cBegin "DISABLE"
    set Log2cEnd "DISABLE"
    set Log2cStep "DISABLE"
    set Log2gBegin "DISABLE"
    set Log2gEnd "DISABLE"
    set Log2gStep "DISABLE"
    set OldModel "0"
    
    .top394.tit69.f.cpd71.f.cpd110.fra80.cpd109.fra72.cpd74 configure -state disable
    .top394.tit69.f.cpd71.f.cpd110.fra80.cpd109.fra72.cpd75 configure -state disable
    .top394.tit69.f.cpd71.f.cpd110.fra80.cpd109.fra72.cpd75 configure -disabledbackground $PSPBackgroundColor

    .top394.tit69.f.cpd71.f.cpd110.fra80.cpd109.fra96.cpd68.lab71 configure -state disable
    .top394.tit69.f.cpd71.f.cpd110.fra80.cpd109.fra96.cpd70 configure -state disable
    .top394.tit69.f.cpd71.f.cpd110.fra80.cpd109.fra96.cpd68.cpd69 configure -state disable

    .top394.tit69.f.cpd71.f.cpd110.fra80.fra66.cpd67.cpd89 configure -state disable
    .top394.tit69.f.cpd71.f.cpd110.fra80.fra66.cpd67.cpd89 configure -disabledbackground $PSPBackgroundColor
    .top394.tit69.f.cpd71.f.cpd110.fra80.fra66.cpd67.cpd90 configure -state disable
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
    wm geometry $top 200x200+175+175; update
    wm maxsize $top 3356 1024
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

proc vTclWindow.top394 {base} {
    if {$base == ""} {
        set base .top394
    }
    if {[winfo exists $base]} {
        wm deiconify $base; return
    }
    set top $base
    ###################
    # CREATING WIDGETS
    ###################
    vTcl:toplevel $top -class Toplevel \
        -menu "$top.m66" -highlightcolor black 
    wm withdraw $top
    wm focusmodel $top passive
    wm geometry $top 600x540+10+110; update
    wm maxsize $top 1604 1184
    wm minsize $top 116 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Data Processing: SVM Supervised Classification"
    vTcl:DefineAlias "$top" "Toplevel394" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.cpd88 \
        -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$top.cpd88" "Frame5" vTcl:WidgetProc "Toplevel394" 1
    set site_3_0 $top.cpd88
    TitleFrame $site_3_0.cpd97 \
        -foreground black -ipad 0 -text {Input Directory} 
    vTcl:DefineAlias "$site_3_0.cpd97" "TitleFrame8" vTcl:WidgetProc "Toplevel394" 1
    bind $site_3_0.cpd97 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd97 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable SupervisedDirInput 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh4" vTcl:WidgetProc "Toplevel394" 1
    frame $site_5_0.cpd92 \
        -borderwidth 2 -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_5_0.cpd92" "Frame19" vTcl:WidgetProc "Toplevel394" 1
    set site_6_0 $site_5_0.cpd92
    button $site_6_0.cpd84 \
        -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images Transparent_Button.gif]] \
        -pady 0 -relief flat -takefocus 0 -text {    } 
    vTcl:DefineAlias "$site_6_0.cpd84" "Button43" vTcl:WidgetProc "Toplevel394" 1
    pack $site_6_0.cpd84 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd85 \
        -in $site_5_0 -anchor center -expand 1 -fill x -side left 
    pack $site_5_0.cpd92 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side top 
    TitleFrame $site_3_0.cpd98 \
        -foreground black -ipad 0 -text {Output Directory} 
    vTcl:DefineAlias "$site_3_0.cpd98" "TitleFrame9" vTcl:WidgetProc "Toplevel394" 1
    bind $site_3_0.cpd98 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_5_0 [$site_3_0.cpd98 getframe]
    entry $site_5_0.cpd85 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #ff0000 -foreground #ff0000 -highlightcolor black \
        -insertbackground black -selectbackground #c4c4c4 \
        -selectforeground black -takefocus 0 \
        -textvariable SupervisedOutputDir 
    vTcl:DefineAlias "$site_5_0.cpd85" "EntryTopXXCh8" vTcl:WidgetProc "Toplevel394" 1
    frame $site_5_0.cpd72 \
        -borderwidth 2 -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_5_0.cpd72" "Frame1" vTcl:WidgetProc "Toplevel394" 1
    set site_6_0 $site_5_0.cpd72
    label $site_6_0.lab73 \
        -foreground black -highlightcolor black -text / 
    vTcl:DefineAlias "$site_6_0.lab73" "Label2" vTcl:WidgetProc "Toplevel394" 1
    entry $site_6_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable SupervisedOutputSubDir -width 3 
    vTcl:DefineAlias "$site_6_0.cpd75" "Entry1" vTcl:WidgetProc "Toplevel394" 1
    pack $site_6_0.lab73 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side left 
    pack $site_6_0.cpd75 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    frame $site_5_0.cpd91 \
        -borderwidth 2 -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_5_0.cpd91" "Frame21" vTcl:WidgetProc "Toplevel394" 1
    set site_6_0 $site_5_0.cpd91
    button $site_6_0.cpd89 \
        \
        -command {global DirName DataDir SupervisedOutputDir SupervisedOutputSubDir FileTrainingArea FileTrainingSet
global NTrainingAreaClass AreaClassN NTrainingArea AreaN AreaPoint AreaPointLig AreaPointCol

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
append FileTrainingSet "/svm_training_cluster_centers.bin"
    
set FileTrainingArea "$SupervisedDirOutput"
if {$SupervisedOutputSubDir != ""} {append FileTrainingArea "/$SupervisedOutputSubDir"}
append FileTrainingArea "/svm_training_areas.txt"

if [file exists $FileTrainingArea] {
    set FileTrainingArea $FileTrainingArea
    } else {
    set FileTrainingArea "Config/svm_training_areas.txt"
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
        -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images OpenDir.gif]] \
        -pady 0 -takefocus 0 -text button 
    bindtags $site_6_0.cpd89 "$site_6_0.cpd89 Button $top all _vTclBalloon"
    bind $site_6_0.cpd89 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open Dir}
    }
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
        -borderwidth 2 -relief groove -height 75 -highlightcolor black \
        -width 125 
    vTcl:DefineAlias "$top.fra55" "Frame9" vTcl:WidgetProc "Toplevel394" 1
    set site_3_0 $top.fra55
    label $site_3_0.lab57 \
        -foreground black -highlightcolor black -text {Init Row} 
    vTcl:DefineAlias "$site_3_0.lab57" "Label10" vTcl:WidgetProc "Toplevel394" 1
    entry $site_3_0.ent58 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable NligInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent58" "Entry6" vTcl:WidgetProc "Toplevel394" 1
    label $site_3_0.lab59 \
        -foreground black -highlightcolor black -text {End Row} 
    vTcl:DefineAlias "$site_3_0.lab59" "Label11" vTcl:WidgetProc "Toplevel394" 1
    entry $site_3_0.ent60 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable NligEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent60" "Entry7" vTcl:WidgetProc "Toplevel394" 1
    label $site_3_0.lab61 \
        -foreground black -highlightcolor black -text {Init Col} 
    vTcl:DefineAlias "$site_3_0.lab61" "Label12" vTcl:WidgetProc "Toplevel394" 1
    entry $site_3_0.ent62 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable NcolInit -width 5 
    vTcl:DefineAlias "$site_3_0.ent62" "Entry8" vTcl:WidgetProc "Toplevel394" 1
    label $site_3_0.lab63 \
        -foreground black -highlightcolor black -text {End Col} 
    vTcl:DefineAlias "$site_3_0.lab63" "Label13" vTcl:WidgetProc "Toplevel394" 1
    entry $site_3_0.ent64 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable NcolEnd -width 5 
    vTcl:DefineAlias "$site_3_0.ent64" "Entry9" vTcl:WidgetProc "Toplevel394" 1
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
    frame $top.fra59 \
        -relief groove -height 35 -highlightcolor black -width 125 
    vTcl:DefineAlias "$top.fra59" "Frame20" vTcl:WidgetProc "Toplevel394" 1
    set site_3_0 $top.fra59
    button $site_3_0.but93 \
        -background #ffff00 \
        -command [list vTcl:DoCmdOption $site_3_0.but93 {global SupervisedDirInput SupervisedDirOutput SupervisedOutputDir SupervisedOutputSubDir SupervisedTrainingProcess
global SupervisedClusterFonction SupervisedSVMClassifierFonction
global BMPSupervised ColorMapSupervised16 FileTrainingArea
global RejectClass RejectRatio ConfusionMatrix Fonction Fonction2 ProgressLine VarWarning WarningMessage WarningMessage2
global OpenDirFile  DataDir Fonction Fonction2 TMPMemoryAllocError

global SVMBatch TMPScriptSVM  TMPTrainingSetNorm  TMPTrainingSet SVMConfigFile SVMRangeFile SVMModelFile ClassificationFile
global TrainingSamplingVal TrainingSampling UnbalanceTraining OldModel NewModel DataFormatActive
global CostVal PolyDeg RBFGamma PolyDegVar RBFGammaVar 
global RBFCV Kernel 
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep
global ProbOut DistOut SVMColorMapSupervised16 DataDirInit

global PolarIndic PolarFiles Npolar PolarIndicSaveList PolarIndicFloatNum
set PolsarProDir [pwd]; append PolsarProDir "/"

set SessionYear [clock format [clock seconds] -format "%Y"]
set SessionMonth [clock format [clock seconds] -format "%m"]
set SessionDay [clock format [clock seconds] -format "%d"]
set SessionHour [clock format [clock seconds] -format "%H"]
set SessionMinute [clock format [clock seconds] -format "%M"]
set SessionSecond [clock format [clock seconds] -format "%S"]
set SessionName $SessionYear;append SessionName "_$SessionMonth";append SessionName "_$SessionDay"
append SessionName "_$SessionHour";append SessionName "_$SessionMinute";append SessionName "_$SessionSecond"

set RejectClass "0"

set SVMBatch "0"
set NewModel "1"
set RBFCV "0"
set Log2cBegin "DISABLE"
set Log2cEnd "DISABLE"
set Log2cStep "DISABLE"
set Log2gBegin "DISABLE"
set Log2gEnd "DISABLE"
set Log2gStep "DISABLE"

if {$PolyDeg != "DISABLE"} { set PolyDeg $PolyDegVar }
if {$RBFGamma != "DISABLE"} { set RBFGamma $RBFGammaVar }

set PolyDegtmp $PolyDeg
set RBFGammatmp $RBFGamma
set CostValtmp $CostVal
set FileTrainingAreatmp $FileTrainingArea
set TrainingSamplingValtmp $TrainingSamplingVal

set Date [clock format [clock seconds] -format "%A %d %B %Y"]

if {$OpenDirFile == 0} {

set config "true"

if {$config == "true"} {

  if {$SupervisedTrainingProcess == 0} {
    set SupervisedDirOutput $SupervisedOutputDir 
    if {$SupervisedOutputSubDir != ""} {append SupervisedDirOutput "/$SupervisedOutputSubDir"}
    }
        
  #####################################################################
  #Create Directory
  set SupervisedDirOutput [PSPCreateDirectoryMask $SupervisedDirOutput $SupervisedOutputDir $SupervisedDirInput]
  #####################################################################       

  if {$OldModel == "0"} {
    set SVMConfigFile "$SupervisedDirOutput/svm_config_file.txt"
    set SVMRangeFile "$SupervisedDirOutput/svm_range_file.txt"
    set SVMModelFile "$SupervisedDirOutput/svm_model_file.txt"
    }
  set ClassificationFile "$SupervisedDirOutput/svm_classification_file.bin"
  set ClassificationFileName "$SupervisedDirOutput/svm_classification_file"
  set InProbClassificationFile "$SupervisedDirOutput/svm_classification_file.bin"; append InProbClassificationFile "_prob"
  set OutProbClassificationFile "$SupervisedDirOutput/svm_classification_file"; append OutProbClassificationFile "_prob.bin"
  set InDistClassificationFile "$SupervisedDirOutput/svm_classification_file.bin"; append InDistClassificationFile "_dist"
  set OutDistClassificationFile "$SupervisedDirOutput/svm_classification_file"; append OutDistClassificationFile "_dist.bin"
    
  set SVMSupervisedDirInput $SupervisedDirInput; append SVMSupervisedDirInput "/"
  set SVMSupervisedDirOutput $SupervisedDirOutput; append SVMSupervisedDirOutput "/"
  set SVMColorMapSupervised16 $ColorMapSupervised16

  if {"$VarWarning"=="ok"} {
    set OffsetLig [expr $NligInit - 1]
    set OffsetCol [expr $NcolInit - 1]
    set FinalNlig [expr $NligEnd - $NligInit + 1]
    set FinalNcol [expr $NcolEnd - $NcolInit + 1]

    if {$RejectClass == "0"} {set RejectRatio "0.0"}

    set TestVarName(0) "Init Row"; set TestVarType(0) "int"; set TestVarValue(0) $NligInit; set TestVarMin(0) "0"; set TestVarMax(0) $NligFullSize
    set TestVarName(1) "Init Col"; set TestVarType(1) "int"; set TestVarValue(1) $NcolInit; set TestVarMin(1) "0"; set TestVarMax(1) $NcolFullSize
    set TestVarName(2) "Final Row"; set TestVarType(2) "int"; set TestVarValue(2) $NligEnd; set TestVarMin(2) $NligInit; set TestVarMax(2) $NligFullSize
    set TestVarName(3) "Final Col"; set TestVarType(3) "int"; set TestVarValue(3) $NcolEnd; set TestVarMin(3) $NcolInit; set TestVarMax(3) $NcolFullSize
    set TestVarName(4) "Reject Ratio"; set TestVarType(4) "float"; set TestVarValue(4) $RejectRatio; set TestVarMin(4) ""; set TestVarMax(4) ""
    set TestVarName(5) "ColorMap16"; set TestVarType(5) "file"; set TestVarValue(5) $ColorMapSupervised16; set TestVarMin(5) ""; set TestVarMax(5) ""

    if {$OldModel == "0"} {
      set TestVarName(6) "Cost"; set TestVarType(6) "int"; set TestVarValue(6) $CostVal; set TestVarMin(6) "1"; set TestVarMax(6) 131072
      set TestVarName(7) "Training Sampling Value"; set TestVarType(7) "int"; set TestVarValue(7) $TrainingSamplingVal; set TestVarMin(7) 100; set TestVarMax(7) 6000
      }

    if {$PolarIndic == "Ipp"} {
      set Npolar "4"
      set PolarFiles "I11.bin I22.bin I12.bin I21.bin"
      set ClassificationColormapFunction "Soft/bin/bmp_process/classification_colormap_SPPIPPC2.exe"
      }

    if {$PolarIndic == "C2"} {
      set Npolar "4"
      set PolarFiles "C11.bin C22.bin C12_real.bin C12_imag.bin"
      set ClassificationColormapFunction "Soft/bin/bmp_process/classification_colormap_SPPIPPC2.exe"
      }

    if {$PolarIndic == "C3"} {
      set Npolar "9"
      set PolarFiles "C11.bin C22.bin C33.bin C12_real.bin C12_imag.bin C13_real.bin C13_imag.bin C23_real.bin C23_imag.bin"
      set ClassificationColormapFunction "Soft/bin/bmp_process/classification_colormap_pauli.exe"
      }

    if {$PolarIndic == "C4"} {
      set Npolar "16"
      set PolarFiles "C11.bin C22.bin C33.bin C44.bin C12_real.bin C12_imag.bin C13_real.bin C13_imag.bin C14_real.bin C14_imag.bin C23_real.bin C23_imag.bin C24_real.bin C24_imag.bin C34_real.bin C34_imag.bin"
      set ClassificationColormapFunction "Soft/bin/bmp_process/classification_colormap_pauli.exe"
      }

    if {$PolarIndic == "T3"} {
      set Npolar "9"
      set PolarFiles "T11.bin T22.bin T33.bin T12_real.bin T12_imag.bin T13_real.bin T13_imag.bin T23_real.bin T23_imag.bin"
      set ClassificationColormapFunction "Soft/bin/bmp_process/classification_colormap_pauli.exe"
      }

    if {$PolarIndic == "T4"} {
      set Npolar "16"
      set PolarFiles "T11.bin T22.bin T33.bin T44.bin T12_real.bin T12_imag.bin T13_real.bin T13_imag.bin T14_real.bin T14_imag.bin T23_real.bin T23_imag.bin T24_real.bin T24_imag.bin T34_real.bin T34_imag.bin"
      set ClassificationColormapFunction "Soft/bin/bmp_process/classification_colormap_pauli.exe"
      }

    if {$PolarIndic == "Other"} {
      if {$Npolar == "0"} {
        set VarError ""
        set ErrorMessage "INVALID Input Polarimetric Indicators"
	Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
	tkwait variable VarError
        }
      }

    if {$TrainingSampling == "0"} {
      set TrainingSamplingVal "0"
      }

    if {$Kernel == "0"} {
      set PolyDeg "DISABLE"
      set PolyDegVar ""
      set RBFCV "0"
      set RBFGamma "DISABLE"
      set RBFGammaVar ""
      set Log2cBegin "DISABLE"
      set Log2cEnd "DISABLE"
      set Log2cStep "DISABLE"
      set Log2gBegin "DISABLE"
      set Log2gEnd "DISABLE"
      set Log2gStep "DISABLE"
      if {$OldModel == "0"} {
        TestVar 8
        }
      }

    if {$Kernel == "1"} {
      set RBFCV "0"
      set RBFGamma "DISABLE"
      set RBFGammaVar ""
      set Log2cBegin "DISABLE"
      set Log2cEnd "DISABLE"
      set Log2cStep "DISABLE"
      set Log2gBegin "DISABLE"
      set Log2gEnd "DISABLE"
      set Log2gStep "DISABLE"
      if {$OldModel == "0"} {
        set TestVarName(8) "Degree"; set TestVarType(8) "int"; set TestVarValue(8) $PolyDeg; set TestVarMin(8) 1; set TestVarMax(9) 4
        TestVar 9
        }
      }

    if {$Kernel == "2"} {
      set PolyDeg "DISABLE"
      set PolyDegVar ""
      if {$RBFCV == "0"} {
	if {$OldModel == "0"} {
	  set TestVarName(8) "Gamma"; set TestVarType(8) "float"; set TestVarValue(8) $RBFGamma; set TestVarMin(8) "0.000976563"; set TestVarMax(8) 4
	  TestVar 9
	  }
      set Log2cBegin "DISABLE"
      set Log2cEnd "DISABLE"
      set Log2cStep "DISABLE"
      set Log2gBegin "DISABLE"
      set Log2gEnd "DISABLE"
      set Log2gStep "DISABLE"
      } else {
      set RBFGamma "DISABLE"
      set RBFGammaVar ""
      }
    }

    if {$OldModel == "1"} {
      TestVar 6
      }
     
    if {$TestVarError == "ok"} {

      WidgetShowTop399; TextEditorRunTrace "Open Window Processing" "b"
   
      # Je teste si l'utilisateur à bien creer le fichier des zones d'entrainement
      if [file exists $FileTrainingArea] {
	if {$OldModel == "0"} {
        set MaskFile "$SupervisedDirInput/mask_valid_pixels.bin"
	  set Fonction ""; set Fonction2 "Supervised Classification"
	  set ProgressLine "0"
	  WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
	  update
	  TextEditorRunTrace "Process The Function $SupervisedSVMClassifierFonction" "k"
	  TextEditorRunTrace "Arguments: $SVMBatch \x22$PolsarProDir\x22 \x22$TMPScriptSVM\x22 \x22$SVMSupervisedDirInput\x22 $BMPSupervised \x22$SVMColorMapSupervised16\x22 \x22$SVMConfigFile\x22 \x22$MaskFile\x22 \x22$SVMSupervisedDirOutput\x22 \x22$FileTrainingArea\x22 \x22$TMPTrainingSet\x22 \x22$SVMRangeFile\x22 \x22$TMPTrainingSetNorm\x22 \x22$SVMModelFile\x22 \x22$ClassificationFile\x22 $TrainingSamplingVal $UnbalanceTraining $NewModel $RBFCV $Log2cBegin $Log2cEnd $Log2cStep $Log2gBegin $Log2gEnd $Log2gStep $Kernel $CostVal $PolyDeg $RBFGamma $ProbOut $DistOut $Npolar $PolarFiles" "k"
	  set f [ open "| $SupervisedClassifierFonction $SVMBatch \x22$PolsarProDir\x22 \x22$TMPScriptSVM\x22 \x22$SVMSupervisedDirInput\x22 $BMPSupervised \x22$SVMColorMapSupervised16\x22 \x22$SVMConfigFile\x22 \x22$MaskFile\x22 \x22$SVMSupervisedDirOutput\x22 \x22$FileTrainingArea\x22 \x22$TMPTrainingSet\x22 \x22$SVMRangeFile\x22 \x22$TMPTrainingSetNorm\x22 \x22$SVMModelFile\x22 \x22$ClassificationFile\x22 $TrainingSamplingVal $UnbalanceTraining $NewModel $RBFCV $Log2cBegin $Log2cEnd $Log2cStep $Log2gBegin $Log2gEnd $Log2gStep $Kernel $CostVal $PolyDeg $RBFGamma $ProbOut $DistOut $Npolar $PolarFiles" r]
	  PsPprogressBar $f
	  TextEditorRunTrace "Check RunTime Errors" "r"
	  CheckRunTimeError
	  WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
	  } else {
	  set Save_NewModel $NewModel
	  set Save_FileTrainingArea $FileTrainingArea
	  set Save_TMPTrainingSet $TMPTrainingSet
	  set Save_TMPTrainingSetNorm $TMPTrainingSetNorm
	  set Save_TrainingSamplingVal $TrainingSamplingVal
	  set Save_UnbalanceTraining $UnbalanceTraining
  
	  set Save_RBFCV $RBFCV
	  set Save_Log2cBegin $Log2cBegin
	  set Save_Log2cEnd $Log2cEnd
	  set Save_Log2cStep $Log2cStep
	  set Save_Log2gBegin $Log2gBegin
	  set Save_Log2gEnd $Log2gEnd
	  set Save_Log2gStep $Log2gStep
	  set Save_CostVal $CostVal
	  set Save_PolyDeg $PolyDeg
	  set Save_RBFGamma $RBFGamma
	
	  set Save_PolarFiles $PolarFiles
	
	  set NewModel "0"
	  set FileTrainingArea "DISABLE"
	  set TMPTrainingSet "DISABLE"
	  set TMPTrainingSetNorm "DISABLE"
	  set TrainingSamplingVal "DISABLE"
	  set UnbalanceTraining "DISABLE"
  
	  set RBFCV "DISABLE"
	  set Log2cBegin "DISABLE"
	  set Log2cEnd "DISABLE"
	  set Log2cStep "DISABLE"
	  set Log2gBegin "DISABLE"
	  set Log2gEnd "DISABLE"
	  set Log2gStep "DISABLE"
	  set CostVal "DISABLE"
	  set PolyDeg "DISABLE"
	  set PolyDegVar ""
	  set RBFGamma "DISABLE"
        set RBFGammaVar ""
	
	  set PolarFiles ""

	  if [file exists $SVMConfigFile] {
            set fileID [open $SVMConfigFile r]
	      set fileData [read $fileID]
	      set fileLines [split $fileData "\n"]
            close $fileID
            set i 0
            foreach line $fileLines {
              if {$i == 15} {
	          set line_Npolar [split $line " "]
                foreach j $line_Npolar {
                  set Npolar $j
                  }
                }	
	      if {$i == 16} {
	        set line_PolarIndic [split $line " "]
	        set l 0
                foreach k $line_PolarIndic {
                  if {$l > 0} {
                    set PolarFile_name $k
                    set PolarFile_name_path "$SVMSupervisedDirInput/$PolarFile_name"
                    incr l
                    if [file exists $PolarFile_name_path] {
                      append PolarFiles $PolarFile_name; append PolarFiles " "
                      } else {
                      set VarError ""
                      set ErrorMessage "ONE OLD MODEL INPUT POLARIMETRIC INDICATOR FILE DOES NOT EXIST" 
                      Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
                      tkwait variable VarError
                      } 
                    }
                    incr l
                  }	
		if {$i == 42} {
		  set line_prob [split $line " "]
                  foreach j $line_prob {
		    if {$ProbOut == "0"} { set ProbOut $j}
                    puts $ProbOut	
                    }	  
		  }
	        if {$i == 43} {
		  set line_dist [split $line " "]
                  foreach j $line_dist {
                    if {$DistOut == "0"} { set DistOut $j}
                    puts $DistOut	
                    }	  
		  }
		}
              incr i 
              }
	    } else {
	    set VarError ""
            set ErrorMessage "SVM CONFIG FILE DOES NOT EXIST" 
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
	    tkwait variable VarError  
	    }

	  if [file exists $SVMRangeFile] {
            if [file exists $SVMModelFile] {
              set MaskFile "$SupervisedDirInput/mask_valid_pixels.bin"
              set SVMConfigFile "$SupervisedDirOutput/svm_config_file.txt"
              set Fonction ""; set Fonction2 "Supervised Classification"
    	        set ProgressLine "0"
              WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
              update
	        TextEditorRunTrace "Process The Function $SupervisedSVMClassifierFonction" "k"        
              TextEditorRunTrace "Arguments: $SVMBatch \x22$PolsarProDir\x22 \x22$TMPScriptSVM\x22 \x22$SVMSupervisedDirInput\x22 $BMPSupervised \x22$SVMColorMapSupervised16\x22 \x22$SVMConfigFile\x22 \x22$MaskFile\x22 \x22$SVMSupervisedDirOutput\x22 \x22$FileTrainingArea\x22 \x22$TMPTrainingSet\x22 \x22$SVMRangeFile\x22 \x22$TMPTrainingSetNorm\x22 \x22$SVMModelFile\x22 \x22$ClassificationFile\x22 $TrainingSamplingVal $UnbalanceTraining $NewModel $RBFCV $Log2cBegin $Log2cEnd $Log2cStep $Log2gBegin $Log2gEnd $Log2gStep $Kernel $CostVal $PolyDeg $RBFGamma $ProbOut $DistOut $Npolar $PolarFiles" "k"
              set f [ open "| $SupervisedClassifierFonction $SVMBatch \x22$PolsarProDir\x22 \x22$TMPScriptSVM\x22 \x22$SVMSupervisedDirInput\x22 $BMPSupervised \x22$SVMColorMapSupervised16\x22 \x22$SVMConfigFile\x22 \x22$MaskFile\x22 \x22$SVMSupervisedDirOutput\x22 \x22$FileTrainingArea\x22 \x22$TMPTrainingSet\x22 \x22$SVMRangeFile\x22 \x22$TMPTrainingSetNorm\x22 \x22$SVMModelFile\x22 \x22$ClassificationFile\x22 $TrainingSamplingVal $UnbalanceTraining $NewModel $RBFCV $Log2cBegin $Log2cEnd $Log2cStep $Log2gBegin $Log2gEnd $Log2gStep $Kernel $CostVal $PolyDeg $RBFGamma $ProbOut $DistOut $Npolar $PolarFiles" r]
	        PsPprogressBar $f
              TextEditorRunTrace "Check RunTime Errors" "r"
              CheckRunTimeError
              WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
              }
	    } else {
	    set VarError ""
          set ErrorMessage "SVM RANGE and/or MODEL FILE DOES NOT EXIST" 
          Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
	    tkwait variable VarError 
	    }

	  set NewModel $Save_NewModel
	  set FileTrainingArea $Save_FileTrainingArea
	  set TMPTrainingSet $Save_TMPTrainingSet
	  set TMPTrainingSetNorm $Save_TMPTrainingSetNorm
	  set TrainingSamplingVal $Save_TrainingSamplingVal
	  set UnbalanceTraining $Save_UnbalanceTraining
  
	  set RBFCV $Save_RBFCV
	  set Log2cBegin $Save_Log2cBegin
	  set Log2cEnd $Save_Log2cEnd
	  set Log2cStep $Save_Log2cStep
	  set Log2gBegin $Save_Log2gBegin
	  set Log2gEnd $Save_Log2gEnd
	  set Log2gStep $Save_Log2gStep
	  set CostVal $Save_CostVal
	  set PolyDeg $Save_PolyDeg
        set PolyDegVar ""; if {$PolyDeg != "DISABLE"} { set PolyDeg $PolyDegVar }
	  set RBFGamma $Save_RBFGamma
        set RBFGammaVar ""; if {$RBFGamma != "DISABLE"} { set RBFGamma $RBFGammaVar }
	
	  set Save_PolarFiles $Save_PolarFiles 
        }

        set ClassificationInputFile "$ClassificationFile"
        if [file exists $ClassificationInputFile] {EnviWriteConfigClassif $ClassificationInputFile $FinalNlig $FinalNcol 4 $ColorMapSupervised16 16}
        
        set InClassificationFileBmp "$SupervisedDirOutput/svm_classification_file.bin.bmp"
        set OutClassificationFileBmp "$SupervisedDirOutput/svm_classification_file.bmp"
        file rename -force -- $InClassificationFileBmp $OutClassificationFileBmp

        if {$ProbOut == "1"} {
          file rename -force -- $InProbClassificationFile $OutProbClassificationFile
          EnviWriteConfig "$OutProbClassificationFile" $FinalNlig $FinalNcol 4
          if {"$BMPProb"=="1"} {
            if [file exists "$OutProbClassificationFile"] {
              set BMPDirInput $SupervisedDirOutput
              set BMPFileInput "$OutProbClassificationFile"
              set BMPFileOutput "$SupervisedDirOutput/svm_classification_file"; append BMPFileOutput "_prob.bmp"
              PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 0 0 1
              } else {
              set VarError ""
              set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
              Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
              tkwait variable VarError
              }
            }
          }
        
        if {$DistOut == "1"} {
          file rename -force -- $InDistClassificationFile $OutDistClassificationFile
          EnviWriteConfig "$OutDistClassificationFile" $FinalNlig $FinalNcol 4
          if {"$BMPDist"=="1"} {
            if [file exists "$OutDistClassificationFile"] {
              set BMPDirInput $SupervisedDirOutput
              set BMPFileInput "$OutDistClassificationFile"
              set BMPFileOutput "$SupervisedDirOutput/svm_classification_file"; append BMPFileOutput "_dist.bmp"
              PSPcreate_bmp_file black $BMPFileInput $BMPFileOutput float real jet  $FinalNcol  $OffsetLig  $OffsetCol  $FinalNlig  $FinalNcol 1 0 0
              } else {
              set VarError ""
              set ErrorMessage "IMPOSSIBLE TO OPEN THE BIN FILES" 
              Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
              tkwait variable VarError
              }
            }
          }
        
        if {$ConfusionMatrix == "1"} {
          set tmp_classification_name "svm_classification_file_"; append tmp_classification_name "$SessionName"
          append tmp_classification_name ".bin"
          set SVMSupervisedClassifierConfusionMatrixFonction "Soft/bin/SVM/svm_confusion_matrix.exe"
          set Fonction ""; set Fonction2 "Confusion Matrix Determination"
          WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
          TextEditorRunTrace "Process The Function $SVMSupervisedClassifierConfusionMatrixFonction" "k"
          TextEditorRunTrace "Arguments: \x22$SupervisedDirInput\x22 \x22$SupervisedDirOutput\x22 \x22$FileTrainingArea\x22  $tmp_classification_name $OffsetLig $OffsetCol $FinalNlig $FinalNcol $BMPSupervised 0 \x22$ColorMapSupervised16\x22" "k"
          set f [ open "| $SVMSupervisedClassifierConfusionMatrixFonction \x22$SupervisedDirInput\x22 \x22$SupervisedDirOutput\x22 \x22$FileTrainingArea\x22 $tmp_classification_name $OffsetLig $OffsetCol $FinalNlig $FinalNcol $BMPSupervised 0 \x22$ColorMapSupervised16\x22" r]
          TextEditorRunTrace "Check RunTime Errors" "r"
          CheckRunTimeError
          WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
          $widget(Button394_7) configure -state normal
          }        

        if {$ColorMapSupervisedCoded == "1"} {
          if [file exists $ClassificationInputFile] {
            set config "full"
            if {$DataFormatActive == "C2"} { set config "dual" }
            if {$DataFormatActive == "IPP"} { set config "dual" }
            if {$config == "full"} {
              if {$ColorMapSupervisedCodedPauli == "1"} {
                set Fonction "Creation of the Supervised Classification BMP File"
                set Fonction2 "Using an automatic color coded (Pauli) ColorMap"
                set MaskCmd ""
                set MaskFile "$SupervisedDirInput/mask_valid_pixels.bin"
                if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
                set ProgressLine "0"
                WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
                update
                set ClassificationOutputFile $ClassificationFileName
                append ClassificationOutputFile "_pauli.bmp"
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/classification_colormap_pauli.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$SupervisedDirInput\x22 -iodf $DataFormatActive -if \x22$ClassificationInputFile\x22 -of \x22$ClassificationOutputFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/bmp_process/classification_colormap_pauli.exe -id \x22$SupervisedDirInput\x22 -iodf $DataFormatActive -if \x22$ClassificationInputFile\x22 -of \x22$ClassificationOutputFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
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
                set ClassificationOutputFile $ClassificationFileName
                append ClassificationOutputFile "_sinclair.bmp"
                TextEditorRunTrace "Process The Function Soft/bin/bmp_process/classification_colormap_sinclair.exe" "k"
                TextEditorRunTrace "Arguments: -id \x22$SupervisedDirInput\x22 -iodf $DataFormatActive -if \x22$ClassificationInputFile\x22 -of \x22$ClassificationOutputFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
                set f [ open "| Soft/bin/bmp_process/classification_colormap_sinclair.exe -id \x22$SupervisedDirInput\x22 -iodf $DataFormatActive -if \x22$ClassificationInputFile\x22 -of \x22$ClassificationOutputFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
                PsPprogressBar $f
                TextEditorRunTrace "Check RunTime Errors" "r"
                CheckRunTimeError
                WidgetHideTop28; TextEditorRunTrace "Close Window Message" "b"
                }
              } else {
              set Fonction "Creation of the Supervised Classification BMP File"
              set Fonction2 "Using an automatic color coded ColorMap"
              set MaskCmd ""
              set MaskFile "$SupervisedDirInput/mask_valid_pixels.bin"
              if [file exists $MaskFile] {set MaskCmd "-mask \x22$MaskFile\x22"}
              set ProgressLine "0"
              WidgetShowTop28; TextEditorRunTrace "Open Window Message" "b"
              update
              set ClassificationOutputFile $ClassificationFileName
              append ClassificationOutputFile "_pauli.bmp"
              TextEditorRunTrace "Process The Function Soft/bin/bmp_process/classification_colormap_SPPIPPC2.exe" "k"
              TextEditorRunTrace "Arguments: -id \x22$SupervisedDirInput\x22 -iodf $DataFormatActive -if \x22$ClassificationInputFile\x22 -of \x22$ClassificationOutputFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgbf RGB1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" "k"
              set f [ open "| Soft/bin/bmp_process/classification_colormap_SPPIPPC2.exe -id \x22$SupervisedDirInput\x22 -iodf $DataFormatActive -if \x22$ClassificationInputFile\x22 -of \x22$ClassificationOutputFile\x22 -ofr $OffsetLig -ofc $OffsetCol -fnr $FinalNlig -fnc $FinalNcol -rgbf RGB1  -errf \x22$TMPMemoryAllocError\x22 $MaskCmd" r]
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
    set PolyDeg $PolyDegtmp
    set PolyDegVar ""; if {$PolyDeg != "DISABLE"} { set PolyDeg $PolyDegVar }
    set RBFGamma $RBFGammatmp
    set RBFGammaVar ""; if {$RBFGamma != "DISABLE"} { set RBFGamma $RBFGammaVar }
    set CostVal $CostValtmp
    set FileTrainingArea $FileTrainingAreatmp
    set TrainingSamplingVal $TrainingSamplingValtmp
    
    WidgetHideTop399; TextEditorRunTrace "Close Window Processing" "b"

    } else {
    if {"$VarWarning"=="no"} {Window hide $widget(Toplevel394); TextEditorRunTrace "Close Window SVM Supervised Classification" "b"}
    }
  }
}}] \
        -foreground black -highlightcolor black -padx 4 -pady 2 \
        -text {Step 6 - Run Classification} 
    vTcl:DefineAlias "$site_3_0.but93" "Button394_1" vTcl:WidgetProc "Toplevel394" 1
    bindtags $site_3_0.but93 "$site_3_0.but93 Button $top all _vTclBalloon"
    bind $site_3_0.but93 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Run the Function}
    }
    button $site_3_0.but24 \
        -background #ffff00 \
        -command {global OpenDirFile MapAlgebraConfigFileSupervised
global PSPTopLevel Load_SVM_PolarIndic Load_SVM_RBFCrossVal

if {$OpenDirFile == 0} {
    if {$MapAlgebraConfigFileSupervised != ""} { set MapAlgebraConfigFileSupervised [MapAlgebra_command $MapAlgebraConfigFileSupervised "quit" ""] }
    Window hide $widget(Toplevel394); TextEditorRunTrace "Close Window SVM Supervised Classification" "b"
}

if {$Load_SVM_RBFCrossVal == 1} {
WidgetHideTop399; TextEditorRunTrace "Close Window Processing" "b"
Window hide $widget(Toplevel395); TextEditorRunTrace "Close Window SVM RBF Cross Validation" "b"
}

if {$Load_SVM_PolarIndic == 1} {
    Window hide $widget(Toplevel396); TextEditorRunTrace "Close Window SVM Polarimetric Indicator Selection" "b"
}} \
        -foreground black -highlightcolor black -padx 4 -pady 2 -takefocus 0 \
        -text Exit 
    vTcl:DefineAlias "$site_3_0.but24" "Button16" vTcl:WidgetProc "Toplevel394" 1
    bindtags $site_3_0.but24 "$site_3_0.but24 Button $top all _vTclBalloon"
    bind $site_3_0.but24 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Exit the Function}
    }
    pack $site_3_0.but93 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.but24 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    TitleFrame $top.cpd66 \
        -foreground #000000 -ipad 0 -text {Step 1 - Training Areas} 
    vTcl:DefineAlias "$top.cpd66" "TitleFrame21" vTcl:WidgetProc "Toplevel394" 1
    bind $top.cpd66 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd66 getframe]
    label $site_4_0.cpd72 \
        -foreground #000000 -highlightcolor #ff0000 -text {Areas File  } 
    vTcl:DefineAlias "$site_4_0.cpd72" "Label278" vTcl:WidgetProc "Toplevel394" 1
    entry $site_4_0.cpd73 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable FileTrainingArea -width 25 
    vTcl:DefineAlias "$site_4_0.cpd73" "Entry191" vTcl:WidgetProc "Toplevel394" 1
    frame $site_4_0.cpd74 \
        -borderwidth 2 -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_4_0.cpd74" "Frame30" vTcl:WidgetProc "Toplevel394" 1
    set site_5_0 $site_4_0.cpd74
    button $site_5_0.cpd105 \
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
        $widget(Button394_1) configure -state normal
        $widget(Checkbutton394_5) configure -state normal
        } else {
        set ErrorMessage "TRAINING AREAS FILE NOT VALID"
        Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
        tkwait variable VarError
        set FileTrainingArea $FileTrainingAreaTmp
        $widget(Button394_1) configure -state disable
        $widget(Checkbutton394_5) configure -state disable
        }
    }} \
        -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -takefocus 0 -text button 
    vTcl:DefineAlias "$site_5_0.cpd105" "Button22" vTcl:WidgetProc "Toplevel394" 1
    bindtags $site_5_0.cpd105 "$site_5_0.cpd105 Button $top all _vTclBalloon"
    bind $site_5_0.cpd105 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    pack $site_5_0.cpd105 \
        -in $site_5_0 -anchor center -expand 0 -fill none -side left 
    frame $site_4_0.cpd69
    set site_5_0 $site_4_0.cpd69
    button $site_5_0.cpd75 \
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
set FileTrainingArea "$SupervisedDirInput/$MapAlgebraSession"; append FileTrainingArea "_svm_training_areas.txt"
DeleteFile $FileTrainingArea
$widget(Button394_1) configure -state disable
$widget(Checkbutton394_5) configure -state disable
MapAlgebra_init "TrainingArea" $MapAlgebraSession $FileTrainingArea
MapAlgebra_launch $MapAlgebraConfigFileSupervised $MapAlgebraBMPFile
WaitUntilCreated $FileTrainingArea
if [file exists $FileTrainingArea] {
    set VarTrainingArea "ok"
    set MapAlgebraConfigFileSupervised [MapAlgebra_command $MapAlgebraConfigFileSupervised "quit" ""]
    set MapAlgebraConfigFileSupervised ""
    $widget(Button394_1) configure -state normal
    $widget(Checkbutton394_5) configure -state normal
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
        -foreground black -highlightcolor black -padx 4 -pady 2 -takefocus 0 \
        -text {Graphic Editor} 
    vTcl:DefineAlias "$site_5_0.cpd75" "Button650" vTcl:WidgetProc "Toplevel394" 1
    bindtags $site_5_0.cpd75 "$site_5_0.cpd75 Button $top all _vTclBalloon"
    bind $site_5_0.cpd75 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Training Areas Graphic Editor}
    }
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 0 -fill x -pady 1 -side top 
    pack $site_4_0.cpd72 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd73 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd69 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 1 -side left 
    TitleFrame $top.cpd67 \
        -foreground #000000 -ipad 0 \
        -text {Step 2 - Classification Configuration} 
    vTcl:DefineAlias "$top.cpd67" "TitleFrame10" vTcl:WidgetProc "Toplevel394" 1
    bind $top.cpd67 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd67 getframe]
    frame $site_4_0.cpd110 \
        -height 123 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_4_0.cpd110" "Frame263" vTcl:WidgetProc "Toplevel394" 1
    set site_5_0 $site_4_0.cpd110
    frame $site_5_0.fra23 \
        -borderwidth 2 -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_5_0.fra23" "Frame270" vTcl:WidgetProc "Toplevel394" 1
    set site_6_0 $site_5_0.fra23
    checkbutton $site_6_0.che24 \
        -foreground black -highlightcolor black -takefocus 0 -text BMP \
        -variable BMPSupervised 
    vTcl:DefineAlias "$site_6_0.che24" "Checkbutton89" vTcl:WidgetProc "Toplevel394" 1
    pack $site_6_0.che24 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_5_0.fra29 \
        -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_5_0.fra29" "Frame273" vTcl:WidgetProc "Toplevel394" 1
    set site_6_0 $site_5_0.fra29
    checkbutton $site_6_0.che30 \
        -foreground black -highlightcolor black -takefocus 0 \
        -text {Confusion Matrix} -variable ConfusionMatrix 
    vTcl:DefineAlias "$site_6_0.che30" "Checkbutton94" vTcl:WidgetProc "Toplevel394" 1
    button $site_6_0.but31 \
        -background #ffff00 \
        -command {global ConfusionMatrix NwinSupervised SupervisedDirOutput OpenDirFile
#UTIL
global Load_TextEdit PSPTopLevel

if {$OpenDirFile == 0} {

if {$ConfusionMatrix == 1} {

    if {$Load_TextEdit == 0} {
        source "GUI/util/TextEdit.tcl"
        set Load_TextEdit 1
        WmTransient $widget(Toplevel95) $PSPTopLevel
        }

    set types {
    {{TXT Files}        {.txt}        }
    }
    set FileName ""
    OpenFile "$SupervisedDirInput" $types "CONFUSION MATRIX FILE"
    
    if {$FileName != ""} {
        set ConfusionMatrixFile $FileName

        if [file exists $ConfusionMatrixFile] {
            TextEditorFromWidget .top394 $ConfusionMatrixFile
            } else {
            set ErrorMessage "CONFUSION MATRIX FILE NOT VALID"
            Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
            tkwait variable VarError
            }
        }
}
}} \
        -foreground black -highlightcolor black -padx 4 -pady 2 -takefocus 0 \
        -text {CM Editor} 
    vTcl:DefineAlias "$site_6_0.but31" "Button394_7" vTcl:WidgetProc "Toplevel394" 1
    bindtags $site_6_0.but31 "$site_6_0.but31 Button $top all _vTclBalloon"
    bind $site_6_0.but31 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Confusion Matrix Editor}
    }
    pack $site_6_0.che30 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.but31 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.fra23 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side left 
    pack $site_5_0.fra29 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side left 
    pack $site_4_0.cpd110 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $top.cpd68 \
        -foreground #000000 -ipad 0 -text {Step 3 - Color Maps} 
    vTcl:DefineAlias "$top.cpd68" "TitleFrame11" vTcl:WidgetProc "Toplevel394" 1
    bind $top.cpd68 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.cpd68 getframe]
    frame $site_4_0.fra90 \
        -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_4_0.fra90" "Frame39" vTcl:WidgetProc "Toplevel394" 1
    set site_5_0 $site_4_0.fra90
    frame $site_5_0.fra91 \
        -borderwidth 2 -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_5_0.fra91" "Frame42" vTcl:WidgetProc "Toplevel394" 1
    set site_6_0 $site_5_0.fra91
    label $site_6_0.cpd95 \
        -foreground black -highlightcolor black -text {ColorMap 16} 
    vTcl:DefineAlias "$site_6_0.cpd95" "Label131" vTcl:WidgetProc "Toplevel394" 1
    pack $site_6_0.cpd95 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side top 
    frame $site_5_0.fra92 \
        -borderwidth 2 -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_5_0.fra92" "Frame43" vTcl:WidgetProc "Toplevel394" 1
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
        -foreground black -highlightcolor black \
        -image [vTcl:image:get_image [file join . GUI Images OpenFile.gif]] \
        -pady 0 -takefocus 0 -text button 
    vTcl:DefineAlias "$site_6_0.but80" "Button6" vTcl:WidgetProc "Toplevel394" 1
    bindtags $site_6_0.but80 "$site_6_0.but80 Button $top all _vTclBalloon"
    bind $site_6_0.but80 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Open File}
    }
    button $site_6_0.cpd102 \
        -background #ffff00 \
        -command {global ColorMapSupervised16 VarColorMap
global ColorMapIn ColorMapOut ColorNumber ColorMapNumber
global RedPalette GreenPalette BluePalette OpenDirFile
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
WidgetShowFromWidget $widget(Toplevel394) $widget(Toplevel38); TextEditorRunTrace "Open Window Colormap" "b"
tkwait variable VarColorMap
if {"$VarColorMap"=="ok"} {
   set ColorMapSupervised16 $ColorMapOut
   }
}} \
        -foreground black -highlightcolor black -padx 4 -pady 2 -takefocus 0 \
        -text Edit 
    vTcl:DefineAlias "$site_6_0.cpd102" "Button46" vTcl:WidgetProc "Toplevel394" 1
    bindtags $site_6_0.cpd102 "$site_6_0.cpd102 Button $top all _vTclBalloon"
    bind $site_6_0.cpd102 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Edit ColorMap}
    }
    pack $site_6_0.but80 \
        -in $site_6_0 -anchor center -expand 0 -fill none -side left 
    pack $site_6_0.cpd102 \
        -in $site_6_0 -anchor center -expand 1 -fill none -side left 
    frame $site_5_0.fra93 \
        -borderwidth 2 -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_5_0.fra93" "Frame44" vTcl:WidgetProc "Toplevel394" 1
    set site_6_0 $site_5_0.fra93
    entry $site_6_0.cpd97 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #0000ff -highlightcolor black \
        -insertbackground black -selectbackground #c4c4c4 \
        -selectforeground black -state disabled -takefocus 0 \
        -textvariable ColorMapSupervised16 -width 40 
    vTcl:DefineAlias "$site_6_0.cpd97" "Entry60" vTcl:WidgetProc "Toplevel394" 1
    pack $site_6_0.cpd97 \
        -in $site_6_0 -anchor center -expand 1 -fill x -side top 
    pack $site_5_0.fra91 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side left 
    pack $site_5_0.fra92 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side right 
    pack $site_5_0.fra93 \
        -in $site_5_0 -anchor center -expand 1 -fill both -side top 
    frame $site_4_0.cpd101 \
        -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_4_0.cpd101" "Frame663" vTcl:WidgetProc "Toplevel394" 1
    set site_5_0 $site_4_0.cpd101
    checkbutton $site_5_0.che24 \
        \
        -command {global ColorMapSupervisedCoded ColorMapSupervisedCodedPauli ColorMapSupervisedCodedSinclair

if {$ColorMapSupervisedCoded == "0"} {
    set ColorMapSupervisedCodedPauli "0"
    set ColorMapSupervisedCodedSinclair "0"
    $widget(Checkbutton394_1) configure -state disable
    $widget(Checkbutton394_2) configure -state disable
    $widget(Label394_1) configure -state disable
    $widget(Label394_2) configure -state disable
    $widget(Label394_3) configure -state disable
    $widget(Label394_4) configure -state disable
    $widget(Label394_5) configure -state disable
    $widget(Label394_6) configure -state disable
    }
if {$ColorMapSupervisedCoded == "1"} {
    $widget(Checkbutton394_1) configure -state normal
    $widget(Checkbutton394_2) configure -state normal
    $widget(Label394_1) configure -state normal
    $widget(Label394_2) configure -state normal
    $widget(Label394_3) configure -state normal
    $widget(Label394_4) configure -state normal
    $widget(Label394_5) configure -state normal
    $widget(Label394_6) configure -state normal
    }} \
        -foreground black -highlightcolor black -takefocus 0 \
        -text {Coded Colormap} -variable ColorMapSupervisedCoded 
    vTcl:DefineAlias "$site_5_0.che24" "Checkbutton641" vTcl:WidgetProc "Toplevel394" 1
    frame $site_5_0.fra25 \
        -borderwidth 2 -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_5_0.fra25" "Frame79" vTcl:WidgetProc "Toplevel394" 1
    set site_6_0 $site_5_0.fra25
    frame $site_6_0.fra38 \
        -borderwidth 2 -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_6_0.fra38" "Frame93" vTcl:WidgetProc "Toplevel394" 1
    set site_7_0 $site_6_0.fra38
    checkbutton $site_7_0.che29 \
        -foreground black -highlightcolor black -takefocus 0 \
        -text {Pauli    } -variable ColorMapSupervisedCodedPauli 
    vTcl:DefineAlias "$site_7_0.che29" "Checkbutton394_1" vTcl:WidgetProc "Toplevel394" 1
    checkbutton $site_7_0.che31 \
        -foreground black -highlightcolor black -takefocus 0 -text Sinclair \
        -variable ColorMapSupervisedCodedSinclair 
    vTcl:DefineAlias "$site_7_0.che31" "Checkbutton394_2" vTcl:WidgetProc "Toplevel394" 1
    pack $site_7_0.che29 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_7_0.che31 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    frame $site_6_0.fra39 \
        -borderwidth 2 -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_6_0.fra39" "Frame94" vTcl:WidgetProc "Toplevel394" 1
    set site_7_0 $site_6_0.fra39
    frame $site_7_0.fra42 \
        -borderwidth 2 -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_7_0.fra42" "Frame82" vTcl:WidgetProc "Toplevel394" 1
    set site_8_0 $site_7_0.fra42
    label $site_8_0.lab47 \
        -foreground #0000ff -highlightcolor black -text |S11+S22| 
    vTcl:DefineAlias "$site_8_0.lab47" "Label394_1" vTcl:WidgetProc "Toplevel394" 1
    label $site_8_0.lab48 \
        -foreground #008000 -highlightcolor black -text |S12+S21| 
    vTcl:DefineAlias "$site_8_0.lab48" "Label394_2" vTcl:WidgetProc "Toplevel394" 1
    label $site_8_0.lab49 \
        -foreground #ff0000 -highlightcolor black -text |S11-S22| 
    vTcl:DefineAlias "$site_8_0.lab49" "Label394_3" vTcl:WidgetProc "Toplevel394" 1
    pack $site_8_0.lab47 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.lab48 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.lab49 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.fra43 \
        -borderwidth 2 -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_7_0.fra43" "Frame86" vTcl:WidgetProc "Toplevel394" 1
    set site_8_0 $site_7_0.fra43
    label $site_8_0.lab52 \
        -foreground #0000ff -highlightcolor black -text |S11| 
    vTcl:DefineAlias "$site_8_0.lab52" "Label394_4" vTcl:WidgetProc "Toplevel394" 1
    label $site_8_0.lab53 \
        -foreground #008000 -highlightcolor black -text |(S12+S21)/2| 
    vTcl:DefineAlias "$site_8_0.lab53" "Label394_5" vTcl:WidgetProc "Toplevel394" 1
    label $site_8_0.lab54 \
        -foreground #ff0000 -highlightcolor black -text |S22| 
    vTcl:DefineAlias "$site_8_0.lab54" "Label394_6" vTcl:WidgetProc "Toplevel394" 1
    pack $site_8_0.lab52 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.lab53 \
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
    TitleFrame $top.tit69 \
        -text {Step 4 - SVM Parameter Setting} 
    vTcl:DefineAlias "$top.tit69" "TitleFrame1" vTcl:WidgetProc "Toplevel394" 1
    bind $top.tit69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_4_0 [$top.tit69 getframe]
    frame $site_4_0.cpd70 \
        -relief groove -height 75 -highlightcolor black -width 193 
    vTcl:DefineAlias "$site_4_0.cpd70" "Frame45" vTcl:WidgetProc "Toplevel394" 1
    set site_5_0 $site_4_0.cpd70
    TitleFrame $site_5_0.cpd69 \
        -foreground #000000 -ipad 0 -text {Input Polarimetric Indicators} 
    vTcl:DefineAlias "$site_5_0.cpd69" "TitleFrame22" vTcl:WidgetProc "Toplevel394" 1
    bind $site_5_0.cpd69 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd69 getframe]
    frame $site_7_0.cpd77 \
        -relief groove -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_7_0.cpd77" "Frame53" vTcl:WidgetProc "Toplevel394" 1
    set site_8_0 $site_7_0.cpd77
    radiobutton $site_8_0.rad91 \
        -borderwidth 0 \
        -command {global PolarIndic DataFormatActive StandardPol
global PolarIndicFloatFlag Load_SVM_PolarIndic RBFGamma RBFGammaVar 


set StandardPol "1"
set PolarIndicFloatFlag "0"
set PolarIndic $DataFormatActive
$widget(Button394_5) configure -state disable
if {$PolarIndic == "Ipp"} {
    set Npolar "4"
    set PolarFiles "I11.bin I22.bin I12.bin I21.bin"
    }

if {$PolarIndic == "C2"} {
    set Npolar "4"
    set PolarFiles "C11.bin C22.bin C12_real.bin C12_imag.bin"
    }

if {$PolarIndic == "C3"} {
    set Npolar "9"
    set PolarFiles "C11.bin C22.bin C33.bin C12_real.bin C12_imag.bin C13_real.bin C13_imag.bin C23_real.bin C23_imag.bin"
    }

if {$PolarIndic == "C4"} {
    set Npolar "16"
    set PolarFiles "C11.bin C22.bin C33.bin C44.bin C12_real.bin C12_imag.bin C13_real.bin C13_imag.bin C14_real.bin C14_imag.bin C23_real.bin C23_imag.bin C24_real.bin C24_imag.bin C34_real.bin C34_imag.bin"
    }

if {$PolarIndic == "T3"} {
    set Npolar "9"
    set PolarFiles "T11.bin T22.bin T33.bin T12_real.bin T12_imag.bin T13_real.bin T13_imag.bin T23_real.bin T23_imag.bin"
    }

if {$PolarIndic == "T4"} {
    set Npolar "16"
    set PolarFiles "T11.bin T22.bin T33.bin T44.bin T12_real.bin T12_imag.bin T13_real.bin T13_imag.bin T14_real.bin T14_imag.bin T23_real.bin T23_imag.bin T24_real.bin T24_imag.bin T34_real.bin T34_imag.bin"
    }

InitRBF

if {$Load_SVM_PolarIndic == 1} {
    Window hide $widget(Toplevel396); TextEditorRunTrace "Close Window SVM Polarimetric Indicator Selection" "b"
}} \
        -foreground black -highlightcolor black -value 1 \
        -variable StandardPol 
    vTcl:DefineAlias "$site_8_0.rad91" "Radiobutton394_1" vTcl:WidgetProc "Toplevel394" 1
    pack $site_8_0.rad91 \
        -in $site_8_0 -anchor center -expand 0 -fill x -padx 2 -side top 
    frame $site_7_0.fra70 \
        -relief groove -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_7_0.fra70" "Frame54" vTcl:WidgetProc "Toplevel394" 1
    set site_8_0 $site_7_0.fra70
    radiobutton $site_8_0.cpd71 \
        \
        -command {global PolarIndic StandardPol PolarIndicFloatFlag

set StandardPol "0"
set PolarIndic "Other"
set PolarIndicFloatFlag "0"
$widget(Button394_5) configure -state normal
InitRBF} \
        -foreground black -highlightcolor black -text Other -value 0 \
        -variable StandardPol 
    vTcl:DefineAlias "$site_8_0.cpd71" "Radiobutton394_2" vTcl:WidgetProc "Toplevel394" 1
    button $site_8_0.cpd72 \
        -background #ffff00 \
        -command {global OpenDirFile SupervisedDirInput
global PolarIndicBinFile RBFGamma RBFGammaVar
global PolarIndicFloatFlag
global Npolar PSPTopLevel
global PolarIndicSaveList Load_SVMSupervisedOtherPolarIndic PolarFiles
global TMPBinFiles
set name ""
set TMPBinFiles ""
    set TMPlist [glob -directory $SupervisedDirInput *.bin]
    set i 0
    foreach line $TMPlist {
        set name [file tail $line]
        lappend TMPBinFiles $name
        }
    
    if {$Load_SVM_PolarIndic == 0} {
        source "GUI/data_process_sngl/SVM_PolarIndic.tcl"
        set Load_SVM_PolarIndic 1
        WmTransient $widget(Toplevel396) $PSPTopLevel
        }
    set RBFGamma "DISABLE"
    set RBFGammaVar ""
    WidgetShowFromWidget $widget(Toplevel394) $widget(Toplevel396); TextEditorRunTrace "Open Window SVM Polarimetric Indicator Selection" "b"
    if { $PolarIndicFloatFlag == 0} {
        set Npolar 0
        set PolarIndicBinFile ""
        set PolarIndicFloatFlag 0
        set PolarFiles ""
        set PolarIndicSaveList ""
        }} \
        -foreground black -highlightcolor black -padx 4 -pady 2 -takefocus 0 \
        -text Select 
    vTcl:DefineAlias "$site_8_0.cpd72" "Button394_5" vTcl:WidgetProc "Toplevel394" 1
    bindtags $site_8_0.cpd72 "$site_8_0.cpd72 Button $top all _vTclBalloon"
    bind $site_8_0.cpd72 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select the other polarimetric indicators}
    }
    pack $site_8_0.cpd71 \
        -in $site_8_0 -anchor center -expand 0 -fill both -side left 
    pack $site_8_0.cpd72 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd77 \
        -in $site_7_0 -anchor w -expand 0 -fill none -side top 
    pack $site_7_0.fra70 \
        -in $site_7_0 -anchor w -expand 1 -fill x -side top 
    TitleFrame $site_5_0.cpd75 \
        -foreground #000000 -ipad 0 -text {Sampling option} 
    vTcl:DefineAlias "$site_5_0.cpd75" "TitleFrame18" vTcl:WidgetProc "Toplevel394" 1
    bind $site_5_0.cpd75 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd75 getframe]
    frame $site_7_0.cpd110 \
        -borderwidth 2 -height 123 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_7_0.cpd110" "Frame382" vTcl:WidgetProc "Toplevel394" 1
    set site_8_0 $site_7_0.cpd110
    frame $site_8_0.fra23 \
        -borderwidth 2 -height 75 -highlightcolor black 
    vTcl:DefineAlias "$site_8_0.fra23" "Frame383" vTcl:WidgetProc "Toplevel394" 1
    set site_9_0 $site_8_0.fra23
    checkbutton $site_9_0.cpd79 \
        -foreground black -highlightcolor black -takefocus 0 \
        -text {If important unbalanced training point} \
        -variable UnbalanceTraining 
    vTcl:DefineAlias "$site_9_0.cpd79" "Checkbutton394_4" vTcl:WidgetProc "Toplevel394" 1
    checkbutton $site_9_0.cpd77 \
        \
        -command {global TrainingSampling

if {$TrainingSampling == "0"} {
$widget(Entry394_4) configure -state disable
$widget(Entry394_4) configure -disabledbackground $PSPBackgroundColor
}
if {$TrainingSampling == "1"} {
$widget(Entry394_4) configure -state normal
$widget(Entry394_4) configure -disabledbackground #FFFFFF
}} \
        -foreground black -highlightcolor black -takefocus 0 \
        -text {Training sampling} -variable TrainingSampling 
    vTcl:DefineAlias "$site_9_0.cpd77" "Checkbutton394_3" vTcl:WidgetProc "Toplevel394" 1
    entry $site_9_0.cpd78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -takefocus 0 \
        -textvariable TrainingSamplingVal -width 5 
    vTcl:DefineAlias "$site_9_0.cpd78" "Entry394_4" vTcl:WidgetProc "Toplevel394" 1
    pack $site_9_0.cpd79 \
        -in $site_9_0 -anchor w -expand 0 -fill none -side bottom 
    pack $site_9_0.cpd77 \
        -in $site_9_0 -anchor w -expand 0 -fill none -side left 
    pack $site_9_0.cpd78 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.fra23 \
        -in $site_8_0 -anchor center -expand 0 -fill both -side left 
    pack $site_7_0.cpd110 \
        -in $site_7_0 -anchor center -expand 1 -fill x -side top 
    TitleFrame $site_5_0.cpd74 \
        -foreground #000000 -ipad 0 -text {Output SVM parameters} 
    vTcl:DefineAlias "$site_5_0.cpd74" "TitleFrame16" vTcl:WidgetProc "Toplevel394" 1
    bind $site_5_0.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_7_0 [$site_5_0.cpd74 getframe]
    frame $site_7_0.cpd110 \
        -borderwidth 2 -height 123 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_7_0.cpd110" "Frame375" vTcl:WidgetProc "Toplevel394" 1
    set site_8_0 $site_7_0.cpd110
    frame $site_8_0.fra23 \
        -borderwidth 2 -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_8_0.fra23" "Frame384" vTcl:WidgetProc "Toplevel394" 1
    set site_9_0 $site_8_0.fra23
    frame $site_9_0.fra74 \
        -relief groove -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_9_0.fra74" "Frame55" vTcl:WidgetProc "Toplevel394" 1
    set site_10_0 $site_9_0.fra74
    checkbutton $site_10_0.cpd75 \
        -borderwidth 0 \
        -command {global ProbOut

if {$ProbOut == "0"} {
$widget(Checkbutton394_6) configure -state disable
}
if {$ProbOut == "1"} {
$widget(Checkbutton394_6) configure -state normal
}} \
        -foreground black -highlightcolor black -takefocus 0 \
        -text {Class Probability} -variable ProbOut 
    vTcl:DefineAlias "$site_10_0.cpd75" "Checkbutton172" vTcl:WidgetProc "Toplevel394" 1
    checkbutton $site_10_0.cpd76 \
        -borderwidth 0 \
        -command {global DistOut

if {$DistOut == "0"} {
$widget(Checkbutton394_7) configure -state disable
}
if {$DistOut == "1"} {
$widget(Checkbutton394_7) configure -state normal
}} \
        -foreground black -highlightcolor black -selectcolor SystemWindow \
        -takefocus 0 -text {Mean Hyperplane Distance} -variable DistOut 
    vTcl:DefineAlias "$site_10_0.cpd76" "Checkbutton177" vTcl:WidgetProc "Toplevel394" 1
    label $site_10_0.lab77 \
        -borderwidth 0 -text {     Useful but time consuming} 
    vTcl:DefineAlias "$site_10_0.lab77" "Label5" vTcl:WidgetProc "Toplevel394" 1
    pack $site_10_0.cpd75 \
        -in $site_10_0 -anchor w -expand 0 -fill none -side top 
    pack $site_10_0.cpd76 \
        -in $site_10_0 -anchor w -expand 0 -fill none -side top 
    pack $site_10_0.lab77 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side top 
    frame $site_9_0.fra77 \
        -relief groove -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_9_0.fra77" "Frame56" vTcl:WidgetProc "Toplevel394" 1
    set site_10_0 $site_9_0.fra77
    checkbutton $site_10_0.cpd78 \
        -foreground black -highlightcolor black -takefocus 0 -text BMP \
        -variable BMPProb 
    vTcl:DefineAlias "$site_10_0.cpd78" "Checkbutton394_6" vTcl:WidgetProc "Toplevel394" 1
    checkbutton $site_10_0.cpd79 \
        -foreground black -highlightcolor black -takefocus 0 -text BMP \
        -variable BMPDist 
    vTcl:DefineAlias "$site_10_0.cpd79" "Checkbutton394_7" vTcl:WidgetProc "Toplevel394" 1
    pack $site_10_0.cpd78 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side top 
    pack $site_10_0.cpd79 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side top 
    pack $site_9_0.fra74 \
        -in $site_9_0 -anchor center -expand 1 -fill y -side left 
    pack $site_9_0.fra77 \
        -in $site_9_0 -anchor center -expand 1 -fill y -side left 
    pack $site_8_0.fra23 \
        -in $site_8_0 -anchor center -expand 0 -fill both -side left 
    pack $site_7_0.cpd110 \
        -in $site_7_0 -anchor center -expand 0 -fill none -side top 
    pack $site_5_0.cpd69 \
        -in $site_5_0 -anchor center -expand 1 -fill both -ipadx 20 \
        -side left 
    pack $site_5_0.cpd75 \
        -in $site_5_0 -anchor center -expand 1 -fill y -side left 
    pack $site_5_0.cpd74 \
        -in $site_5_0 -anchor center -expand 0 -fill y -side right 
    TitleFrame $site_4_0.cpd71 \
        -foreground #000000 -ipad 0 -relief sunken \
        -text {Step 5 - Kernel Parameter} 
    vTcl:DefineAlias "$site_4_0.cpd71" "TitleFrame23" vTcl:WidgetProc "Toplevel394" 1
    bind $site_4_0.cpd71 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd71 getframe]
    frame $site_6_0.cpd110 \
        -height 123 -highlightcolor black -width 14 
    vTcl:DefineAlias "$site_6_0.cpd110" "Frame361" vTcl:WidgetProc "Toplevel394" 1
    set site_7_0 $site_6_0.cpd110
    frame $site_7_0.fra72 \
        -borderwidth 2 -height 75 -highlightcolor black -width 53 
    vTcl:DefineAlias "$site_7_0.fra72" "Frame87" vTcl:WidgetProc "Toplevel394" 1
    set site_8_0 $site_7_0.fra72
    label $site_8_0.cpd79 \
        -foreground black -highlightcolor black -text Cost 
    vTcl:DefineAlias "$site_8_0.cpd79" "Label394_10" vTcl:WidgetProc "Toplevel394" 1
    entry $site_8_0.cpd78 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -takefocus 0 -textvariable CostVal -width 5 
    vTcl:DefineAlias "$site_8_0.cpd78" "Entry394_5" vTcl:WidgetProc "Toplevel394" 1
    pack $site_8_0.cpd79 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_8_0.cpd78 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    frame $site_7_0.fra80 \
        -borderwidth 2 -height 75 -highlightcolor black -width 193 
    vTcl:DefineAlias "$site_7_0.fra80" "Frame88" vTcl:WidgetProc "Toplevel394" 1
    set site_8_0 $site_7_0.fra80
    frame $site_8_0.cpd109 \
        -borderwidth 2 -relief groove -height 75 -highlightcolor black \
        -width 125 
    vTcl:DefineAlias "$site_8_0.cpd109" "Frame89" vTcl:WidgetProc "Toplevel394" 1
    set site_9_0 $site_8_0.cpd109
    frame $site_9_0.fra96 \
        -relief groove -height 75 -highlightcolor black -width 125 
    vTcl:DefineAlias "$site_9_0.fra96" "Frame90" vTcl:WidgetProc "Toplevel394" 1
    set site_10_0 $site_9_0.fra96
    frame $site_10_0.cpd68 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_10_0.cpd68" "Frame6" vTcl:WidgetProc "Toplevel394" 1
    set site_11_0 $site_10_0.cpd68
    checkbutton $site_11_0.cpd69 \
        -borderwidth 0 \
        -command {global FileTrainingArea RBFCV

if {$RBFCV == 0} {
    $widget(Button394_6) configure -state disable
    }
if {$RBFCV == 1} {
    if [file exists $FileTrainingArea] {
        $widget(Button394_6) configure -state normal
        } else {
        set ErrorMessage "You need select Training Area" 
	Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
	tkwait variable VarError
        }
    }} \
        -foreground #ff0000 -highlightcolor black -takefocus 0 \
        -text RECOMMANDED -variable RBFCV 
    vTcl:DefineAlias "$site_11_0.cpd69" "Checkbutton394_5" vTcl:WidgetProc "Toplevel394" 1
    label $site_11_0.lab71 \
        -borderwidth 0 -text {Optimisation parameters} 
    vTcl:DefineAlias "$site_11_0.lab71" "Label394_12" vTcl:WidgetProc "Toplevel394" 1
    pack $site_11_0.cpd69 \
        -in $site_11_0 -anchor center -expand 0 -fill none -side top 
    pack $site_11_0.lab71 \
        -in $site_11_0 -anchor center -expand 0 -fill none -side top 
    button $site_10_0.cpd70 \
        -background #ffff00 \
        -command {global OpenDirFile SupervisedDirInput FileTrainingArea
global PolarIndicBinFile ENVIHdrFile ENVICommonFormatFlag
global PolarIndicFloatFlag Npolar
global ENVIFloatOutputFile PSPTopLevel
global PolarIndicSaveList Load_SVM_RBFCrossVal PolarFiles
global RBFCV Kernel 
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep

global CBegin CEnd GStep
global GBegin GEnd GStep

if [file exists $FileTrainingArea] {
    if {$Load_SVM_RBFCrossVal == 0} {
        source "GUI/data_process_sngl/SVM_RBFCrossVal.tcl"
        set Load_SVM_RBFCrossVal 1
        WmTransient $widget(Toplevel395) $PSPTopLevel
        }
    $widget(Button394_1) configure -state disable
    $widget(Button395_1) configure -state disable
    WidgetShowFromWidget $widget(Toplevel394) $widget(Toplevel395); TextEditorRunTrace "Open Window SVM RBF Cross Validation" "b"
    set Log2cBegin 8
    set Log2cEnd 14
    set Log2cStep 2
    set Log2gBegin -5
    set Log2gEnd 0
    set Log2gStep 1
    
    set CBegin [expr pow(2,$Log2cBegin)]
    set CEnd [expr pow(2,$Log2cEnd)]
    set CStep [expr pow(2,$Log2cStep)]
    
    set GBegin [expr pow(2,$Log2gBegin)]
    set GEnd [expr pow(2,$Log2gEnd)]
    set GStep [expr pow(2,$Log2gStep)]
    } else {
    set ErrorMessage "You need to select training Area"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    }} \
        -foreground black -highlightcolor black -padx 4 -pady 2 -takefocus 0 \
        -text {Setup and Run} 
    vTcl:DefineAlias "$site_10_0.cpd70" "Button394_6" vTcl:WidgetProc "Toplevel394" 1
    bindtags $site_10_0.cpd70 "$site_10_0.cpd70 Button $top all _vTclBalloon"
    bind $site_10_0.cpd70 <<SetBalloon>> {
        set ::vTcl::balloon::%W {Select the other polarimetric indicators}
    }
    pack $site_10_0.cpd68 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side top 
    pack $site_10_0.cpd70 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side top 
    frame $site_9_0.fra72 \
        -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_9_0.fra72" "Frame7" vTcl:WidgetProc "Toplevel394" 1
    set site_10_0 $site_9_0.fra72
    radiobutton $site_10_0.cpd73 \
        -borderwidth 0 \
        -command {global TrainingSamplingVal TrainingSampling UnbalanceTraining OldModel NewModel
global CostVal PolyDeg RBFGamma PolyDegVar RBFGammaVar Npolar
global RBFCV Kernel 
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep
global PolarIndic

if {$Npolar == 0} {
    set VarError ""
    set ErrorMessage "CHOOSE POLARIMETRIC INDICATORS BEFORE SELECTING THE KERNEL"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    ResetRBF
    } else {
    InitRBF
    }} \
        -foreground black -highlightcolor black -text RBF -value 2 \
        -variable Kernel 
    vTcl:DefineAlias "$site_10_0.cpd73" "Radiobutton394_3" vTcl:WidgetProc "Toplevel394" 1
    label $site_10_0.cpd74 \
        -borderwidth 0 -foreground black -highlightcolor black \
        -text {Gamma = 1/sigma} 
    vTcl:DefineAlias "$site_10_0.cpd74" "Label394_11" vTcl:WidgetProc "Toplevel394" 1
    entry $site_10_0.cpd75 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -takefocus 0 -textvariable RBFGammaVar \
        -width 6 
    vTcl:DefineAlias "$site_10_0.cpd75" "Entry394_6" vTcl:WidgetProc "Toplevel394" 1
    pack $site_10_0.cpd73 \
        -in $site_10_0 -anchor nw -expand 0 -fill none -side top 
    pack $site_10_0.cpd74 \
        -in $site_10_0 -anchor w -expand 0 -fill none -padx 5 -side left 
    pack $site_10_0.cpd75 \
        -in $site_10_0 -anchor center -expand 0 -fill none -side top 
    pack $site_9_0.fra96 \
        -in $site_9_0 -anchor center -expand 1 -fill none -padx 10 \
        -side right 
    pack $site_9_0.fra72 \
        -in $site_9_0 -anchor nw -expand 1 -fill none -padx 5 -side left 
    frame $site_8_0.fra66 \
        -borderwidth 2 -relief groove -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra66" "Frame8" vTcl:WidgetProc "Toplevel394" 1
    set site_9_0 $site_8_0.fra66
    frame $site_9_0.cpd67 \
        -height 75 -highlightcolor black -width 157 
    vTcl:DefineAlias "$site_9_0.cpd67" "Frame95" vTcl:WidgetProc "Toplevel394" 1
    set site_10_0 $site_9_0.cpd67
    radiobutton $site_10_0.cpd104 \
        -borderwidth 0 \
        -command {global TrainingSamplingVal TrainingSampling UnbalanceTraining OldModel NewModel
global CostVal PolyDeg RBFGamma PolyDegVar RBFGammaVar Npolar
global RBFCV Kernel Load_SVM_RBFCrossVal
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep

if {$Npolar == 0} {
    set VarError ""
    set ErrorMessage "CHOOSE POLARIMETRIC INDICATORS BEFORE SELECTING THE KERNEL"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    ResetRBF
    } else {
    set PolyDeg "2"
    set PolyDegVar "2"
    set RBFCV "0"
    set RBFGammaVar  ""
    set RBFGamma  "DISABLE"
    set Log2cBegin "DISABLE"
    set Log2cEnd "DISABLE"
    set Log2cStep "DISABLE"
    set Log2gBegin "DISABLE"
    set Log2gEnd "DISABLE"
    set Log2gStep "DISABLE"
    set OldModel "0"
    $widget(Label394_11) configure -state disable
    $widget(Entry394_6) configure -state disable
    $widget(Entry394_6) configure -disabledbackground $PSPBackgroundColor
    $widget(Label394_12) configure -state disable
    $widget(Button394_6) configure -state disable
    $widget(Checkbutton394_5) configure -state disable

    $widget(Entry394_7) configure -state normal
    $widget(Entry394_7) configure -disabledbackground #FFFFFF
    $widget(Label394_13) configure -state normal
    }

if {$Load_SVM_RBFCrossVal == 1} {
Window hide $widget(Toplevel395); TextEditorRunTrace "Close Window SVM RBF Cross Validation" "b"
}} \
        -disabledforeground #999999 -foreground black -highlightcolor black \
        -text Polynomial -value 1 -variable Kernel 
    vTcl:DefineAlias "$site_10_0.cpd104" "Radiobutton394_4" vTcl:WidgetProc "Toplevel394" 1
    label $site_10_0.cpd90 \
        -foreground black -highlightcolor black -text Degree 
    vTcl:DefineAlias "$site_10_0.cpd90" "Label394_13" vTcl:WidgetProc "Toplevel394" 1
    entry $site_10_0.cpd89 \
        -background white -disabledbackground #ffffff \
        -disabledforeground #0000ff -foreground #ff0000 -highlightcolor black \
        -insertbackground black -justify center -selectbackground #c4c4c4 \
        -selectforeground black -takefocus 0 -textvariable PolyDegVar \
        -width 5 
    vTcl:DefineAlias "$site_10_0.cpd89" "Entry394_7" vTcl:WidgetProc "Toplevel394" 1
    pack $site_10_0.cpd104 \
        -in $site_10_0 -anchor w -expand 0 -fill none -side top 
    pack $site_10_0.cpd90 \
        -in $site_10_0 -anchor w -expand 0 -fill none -padx 5 -side left 
    pack $site_10_0.cpd89 \
        -in $site_10_0 -anchor w -expand 0 -fill none -side left 
    pack $site_9_0.cpd67 \
        -in $site_9_0 -anchor center -expand 0 -fill none -padx 5 -side top 
    frame $site_8_0.fra79 \
        -borderwidth 2 -relief groove -height 75 -highlightcolor black \
        -width 125 
    vTcl:DefineAlias "$site_8_0.fra79" "Frame13" vTcl:WidgetProc "Toplevel394" 1
    set site_9_0 $site_8_0.fra79
    radiobutton $site_9_0.cpd80 \
        -borderwidth 0 \
        -command {global TrainingSamplingVal TrainingSampling UnbalanceTraining OldModel NewModel
global CostVal PolyDeg RBFGamma PolyDegVar RBFGammaVar
global RBFCV Kernel Load_SVM_RBFCrossVal
global Log2cBegin Log2cEnd Log2cStep
global Log2gBegin Log2gEnd Log2gStep

if {$Npolar == 0} {
    set VarError ""
    set ErrorMessage "CHOOSE POLARIMETRIC INDICATORS BEFORE SELECTING THE KERNEL"
    Window show $widget(Toplevel44); TextEditorRunTrace "Open Window Error" "b"
    tkwait variable VarError
    ResetRBF
    } else {
    set PolyDegVar ""
    set PolyDeg "DISABLE"
    set RBFCV "0"
    set RBFGammaVar ""
    set RBFGamma "DISABLE"
    set Log2cBegin "DISABLE"
    set Log2cEnd "DISABLE"
    set Log2cStep "DISABLE"
    set Log2gBegin "DISABLE"
    set Log2gEnd "DISABLE"
    set Log2gStep "DISABLE"
    set OldModel "0"
    $widget(Label394_11) configure -state disable
    $widget(Entry394_6) configure -state disable
    $widget(Entry394_6) configure -disabledbackground $PSPBackgroundColor
    $widget(Label394_12) configure -state disable
    $widget(Button394_6) configure -state disable
    $widget(Checkbutton394_5) configure -state disable

    $widget(Entry394_7) configure -state disable
    $widget(Entry394_7) configure -disabledbackground $PSPBackgroundColor
    $widget(Label394_13) configure -state disable
    }

if {$Load_SVM_RBFCrossVal == 1} {
Window hide $widget(Toplevel395); TextEditorRunTrace "Close Window SVM RBF Cross Validation" "b"
}} \
        -foreground black -highlightcolor black -text Linear -value 0 \
        -variable Kernel 
    vTcl:DefineAlias "$site_9_0.cpd80" "Radiobutton394_5" vTcl:WidgetProc "Toplevel394" 1
    pack $site_9_0.cpd80 \
        -in $site_9_0 -anchor w -expand 0 -fill none -padx 5 -side top 
    pack $site_8_0.cpd109 \
        -in $site_8_0 -anchor center -expand 1 -fill y -side left 
    pack $site_8_0.fra66 \
        -in $site_8_0 -anchor center -expand 1 -fill y -side left 
    pack $site_8_0.fra79 \
        -in $site_8_0 -anchor center -expand 1 -fill y -side left 
    pack $site_7_0.fra72 \
        -in $site_7_0 -anchor center -expand 0 -fill both -padx 5 -side left 
    pack $site_7_0.fra80 \
        -in $site_7_0 -anchor center -expand 1 -fill both -side left 
    pack $site_6_0.cpd110 \
        -in $site_6_0 -anchor center -expand 1 -fill both -side top 
    pack $site_4_0.cpd70 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    pack $site_4_0.cpd71 \
        -in $site_4_0 -anchor center -expand 1 -fill x -side top 
    menu $top.m66 \
        -activeborderwidth 1 -borderwidth 1 -tearoff 1 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.cpd88 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra55 \
        -in $top -anchor center -expand 0 -fill x -pady 2 -side top 
    pack $top.fra59 \
        -in $top -anchor center -expand 1 -fill x -side bottom 
    pack $top.cpd66 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd67 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.cpd68 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.tit69 \
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
Window show .top394

main $argc $argv
