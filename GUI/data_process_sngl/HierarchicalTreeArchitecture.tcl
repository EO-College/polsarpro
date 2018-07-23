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

        {{[file join . GUI Images TreeNode.gif]} {user image} user {}}
        {{[file join . GUI Images TreeVide.gif]} {user image} user {}}
        {{[file join . GUI Images TreeRightCorner.gif]} {user image} user {}}
        {{[file join . GUI Images TreeClass.gif]} {user image} user {}}
        {{[file join . GUI Images TreeLeftCorner.gif]} {user image} user {}}
        {{[file join . GUI Images TreeVertLine.gif]} {user image} user {}}
        {{[file join . GUI Images TreeHorzLine.gif]} {user image} user {}}
        {{[file join . GUI Images help.gif]} {user image} user {}}
        {{[file join . GUI Images TreeLeftDiag.gif]} {user image} user {}}
        {{[file join . GUI Images TreeRightDiag.gif]} {user image} user {}}

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
    set base .top263
    namespace eval ::widgets::$base {
        set set,origin 1
        set set,size 1
        set runvisible 1
    }
    namespace eval ::widgets::$base.fra74 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra74
    namespace eval ::widgets::$site_3_0.fra175 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra175
    namespace eval ::widgets::$site_4_0.lab176 {
        array set save {-borderwidth 1}
    }
    namespace eval ::widgets::$site_3_0.cpd172 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd172
    namespace eval ::widgets::$site_4_0.cpd138 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd163 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd164 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd129 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd142 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd87 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd165 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd125 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd168 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd167 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd139 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd145 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd147 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd173 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd148 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd113 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd146 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd140 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd141 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd144 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd169 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd174 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd170 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd89 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd81 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd149 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd166 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd171 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd171
    namespace eval ::widgets::$site_4_0.cpd128 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd157 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd143 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd94 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd88 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd96 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd100 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd158 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd150 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd102 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd152 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd104 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd151 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd153 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd154 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd155 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd130 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd106 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd160 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd159 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd161 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd161
    namespace eval ::widgets::$site_4_0.cpd138 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd163 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd164 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd129 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd139 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd167 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd168 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd107 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd140 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd141 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd144 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd142 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd81 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd87 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd165 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd125 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd145 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd147 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd148 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd113 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd146 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd169 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd170 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd89 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd149 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd166 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd156 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd156
    namespace eval ::widgets::$site_4_0.cpd128 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd88 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd157 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd143 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd94 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd96 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd100 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd158 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd150 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd102 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd152 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd103 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd104 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd151 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd153 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd160 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd106 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd154 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd155 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd130 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd159 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd136 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd136
    namespace eval ::widgets::$site_4_0.cpd138 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd129 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd139 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd107 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd140 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd142 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd124 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd141 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd111 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd144 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd81 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd87 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd125 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd145 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd113 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd146 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd89 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd149 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd126 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd147 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd115 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd148 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd135 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd135
    namespace eval ::widgets::$site_4_0.cpd128 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd88 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd89 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd143 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd94 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd96 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd100 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd97 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd150 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd102 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd152 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd103 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd104 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd151 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd153 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd105 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd106 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd154 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd155 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd130 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.fra73 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra73
    namespace eval ::widgets::$site_4_0.cpd129 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd107 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd123 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd109 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd124 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd111 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd81 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd125 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd113 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd126 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd115 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd131 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd117 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd87 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd132 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd119 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd88 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd89 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd133 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd120 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd134 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd90 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd90
    namespace eval ::widgets::$site_4_0.cpd128 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd81 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd87 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd88 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd89 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd94 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd95 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd96 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd97 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd99 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd100 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd101 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd102 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd103 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd104 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd105 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd106 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd130 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd122 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd122
    namespace eval ::widgets::$site_4_0.cpd127 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd107 {
        array set save {-borderwidth 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd108 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd109 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd110 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd111 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd112 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd81 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd113 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd114 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd115 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd116 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd117 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd118 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd87 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd119 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd88 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd120 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd89 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd121 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd75 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd75
    namespace eval ::widgets::$site_4_0.cpd123 {
        array set save {}
    }
    namespace eval ::widgets::$site_4_0.cpd128 {
        array set save {-borderwidth 1 -highlightthickness 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd75 {
        array set save {-borderwidth 1 -highlightthickness 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd76 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd77 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd78 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd79 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd80 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd81 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd82 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd83 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd84 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd85 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd86 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd87 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd88 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd89 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd94 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd95 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd96 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd97 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd99 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd100 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd101 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd102 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd103 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd104 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd105 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd106 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd130 {
        array set save {-borderwidth 1 -image 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd73 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd73
    namespace eval ::widgets::$site_4_0.cpd92 {
        array set save {}
    }
    namespace eval ::widgets::$site_4_0.cpd90 {
        array set save {-borderwidth 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-borderwidth 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd93 {
        array set save {-borderwidth 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd107 {
        array set save {-borderwidth 1 -command 1 -highlightthickness 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd94 {
        array set save {-borderwidth 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd108 {
        array set save {-borderwidth 1 -command 1 -highlightthickness 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd95 {
        array set save {-borderwidth 1 -command 1 -highlightthickness 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd109 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd96 {
        array set save {-borderwidth 1 -command 1 -highlightthickness 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd110 {
        array set save {-borderwidth 1 -command 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd111 {
        array set save {-borderwidth 1 -command 1 -highlightthickness 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd97 {
        array set save {-borderwidth 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd112 {
        array set save {-borderwidth 1 -command 1 -highlightthickness 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd98 {
        array set save {-borderwidth 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd113 {
        array set save {-borderwidth 1 -command 1 -highlightthickness 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd99 {
        array set save {-borderwidth 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd114 {
        array set save {-borderwidth 1 -command 1 -highlightthickness 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd100 {
        array set save {-borderwidth 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd115 {
        array set save {-borderwidth 1 -command 1 -highlightthickness 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd101 {
        array set save {-borderwidth 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd116 {
        array set save {-borderwidth 1 -command 1 -highlightthickness 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd102 {
        array set save {-borderwidth 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd117 {
        array set save {-borderwidth 1 -command 1 -highlightthickness 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd103 {
        array set save {-borderwidth 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd118 {
        array set save {-borderwidth 1 -command 1 -highlightthickness 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd104 {
        array set save {-borderwidth 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd119 {
        array set save {-borderwidth 1 -command 1 -highlightthickness 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd105 {
        array set save {-borderwidth 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd120 {
        array set save {-borderwidth 1 -command 1 -highlightthickness 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd106 {
        array set save {-borderwidth 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd121 {
        array set save {-borderwidth 1 -command 1 -highlightthickness 1 -image 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_4_0.cpd122 {
        array set save {-borderwidth 1 -command 1 -image 1 -padx 1 -pady 1 -relief 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd177 {
        array set save {-height 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd177
    namespace eval ::widgets::$site_4_0.lab176 {
        array set save {-borderwidth 1}
    }
    namespace eval ::widgets::$base.fra118 {
        array set save {-height 1 -width 1}
    }
    set site_3_0 $base.fra118
    namespace eval ::widgets::$site_3_0.cpd119 {
        array set save {-borderwidth 1 -height 1 -relief 1 -width 1}
    }
    set site_4_0 $site_3_0.cpd119
    namespace eval ::widgets::$site_4_0.rad112 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.rad113 {
        array set save {-command 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_4_0.fra114 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra114
    namespace eval ::widgets::$site_5_0.lab115 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_5_0.ent116 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_3_0.fra73 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_4_0 $site_3_0.fra73
    namespace eval ::widgets::$site_4_0.cpd74 {
        array set save {-ipad 1 -text 1}
    }
    set site_6_0 [$site_4_0.cpd74 getframe]
    namespace eval ::widgets::$site_6_0 {
        array set save {}
    }
    set site_6_0 $site_6_0
    namespace eval ::widgets::$site_6_0.fra75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra75
    namespace eval ::widgets::$site_7_0.cpd76 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd76
    namespace eval ::widgets::$site_8_0.lab122 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd74 {
        array set save {-entrybg 1 -takefocus 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd77 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd77
    namespace eval ::widgets::$site_8_0.lab122 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.cpd75 {
        array set save {-entrybg 1 -takefocus 1 -textvariable 1}
    }
    namespace eval ::widgets::$site_6_0.fra127 {
        array set save {-height 1 -width 1}
    }
    set site_7_0 $site_6_0.fra127
    namespace eval ::widgets::$site_7_0.fra128 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.fra128
    namespace eval ::widgets::$site_8_0.lab129 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.ent130 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.cpd131 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd131
    namespace eval ::widgets::$site_8_0.lab129 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.ent130 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_7_0.fra133 {
        array set save {-height 1 -width 1}
    }
    set site_8_0 $site_7_0.fra133
    namespace eval ::widgets::$site_8_0.lab135 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.fra134 {
        array set save {-height 1 -width 1}
    }
    set site_9_0 $site_8_0.fra134
    namespace eval ::widgets::$site_9_0.rad136 {
        array set save {-borderwidth 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_9_0.cpd137 {
        array set save {-borderwidth 1 -text 1 -value 1 -variable 1}
    }
    namespace eval ::widgets::$site_7_0.cpd132 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_8_0 $site_7_0.cpd132
    namespace eval ::widgets::$site_8_0.lab129 {
        array set save {-text 1}
    }
    namespace eval ::widgets::$site_8_0.ent130 {
        array set save {-background 1 -foreground 1 -justify 1 -textvariable 1 -width 1}
    }
    namespace eval ::widgets::$site_4_0.fra75 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_5_0 $site_4_0.fra75
    namespace eval ::widgets::$site_5_0.cpd76 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$base.fra142 {
        array set save {-borderwidth 1 -height 1 -width 1}
    }
    set site_3_0 $base.fra142
    namespace eval ::widgets::$site_3_0.cpd78 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd145 {
        array set save {-background 1 -image 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets::$site_3_0.cpd146 {
        array set save {-background 1 -command 1 -padx 1 -pady 1 -text 1}
    }
    namespace eval ::widgets_bindings {
        set tagslist _TopLevel
    }
    namespace eval ::vTcl::modules::main {
        set procs {
            init
            main
            TreeInitWidget
            TreeInitStructure
            TreeCreateClass
            TreeDisableBranch
            TreeCreateNode
            TreeEnableBranch
            TreeNodeRAZ
            TreeActiveNode
            NodeON
            ClassON
            TreeConstructStructure
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
## Procedure:  TreeInitWidget

proc ::TreeInitWidget {} {
global But263 Lbl263
    
set But263(0) 0        
for {set i 0} {$i <= 64} {incr i} { set But263($i) "" }

set But263(1) .top263.fra74.cpd172.cpd113
set But263(2) .top263.fra74.cpd161.cpd107
set But263(3) .top263.fra74.cpd161.cpd113
set But263(4) .top263.fra74.cpd136.cpd107
set But263(5) .top263.fra74.cpd136.cpd111
set But263(6) .top263.fra74.cpd136.cpd113
set But263(7) .top263.fra74.cpd136.cpd115
set But263(8) .top263.fra74.fra73.cpd107
set But263(9) .top263.fra74.fra73.cpd109
set But263(10) .top263.fra74.fra73.cpd111
set But263(11) .top263.fra74.fra73.cpd113
set But263(12) .top263.fra74.fra73.cpd115
set But263(13) .top263.fra74.fra73.cpd117
set But263(14) .top263.fra74.fra73.cpd119
set But263(15) .top263.fra74.fra73.cpd120
set But263(16) .top263.fra74.cpd122.cpd74
set But263(17) .top263.fra74.cpd122.cpd107
set But263(18) .top263.fra74.cpd122.cpd108
set But263(19) .top263.fra74.cpd122.cpd109
set But263(20) .top263.fra74.cpd122.cpd110
set But263(21) .top263.fra74.cpd122.cpd111
set But263(22) .top263.fra74.cpd122.cpd112
set But263(23) .top263.fra74.cpd122.cpd113
set But263(24) .top263.fra74.cpd122.cpd114
set But263(25) .top263.fra74.cpd122.cpd115
set But263(26) .top263.fra74.cpd122.cpd116
set But263(27) .top263.fra74.cpd122.cpd117
set But263(28) .top263.fra74.cpd122.cpd118
set But263(29) .top263.fra74.cpd122.cpd119
set But263(30) .top263.fra74.cpd122.cpd120
set But263(31) .top263.fra74.cpd122.cpd121
set But263(32) .top263.fra74.cpd73.cpd90
set But263(33) .top263.fra74.cpd73.cpd74
set But263(34) .top263.fra74.cpd73.cpd93
set But263(35) .top263.fra74.cpd73.cpd107
set But263(36) .top263.fra74.cpd73.cpd94
set But263(37) .top263.fra74.cpd73.cpd108
set But263(38) .top263.fra74.cpd73.cpd95
set But263(39) .top263.fra74.cpd73.cpd109
set But263(40) .top263.fra74.cpd73.cpd96
set But263(41) .top263.fra74.cpd73.cpd110
set But263(42) .top263.fra74.cpd73.cpd111
set But263(43) .top263.fra74.cpd73.cpd97
set But263(44) .top263.fra74.cpd73.cpd112
set But263(45) .top263.fra74.cpd73.cpd98
set But263(46) .top263.fra74.cpd73.cpd113
set But263(47) .top263.fra74.cpd73.cpd99
set But263(48) .top263.fra74.cpd73.cpd114
set But263(49) .top263.fra74.cpd73.cpd100
set But263(50) .top263.fra74.cpd73.cpd115
set But263(51) .top263.fra74.cpd73.cpd101
set But263(52) .top263.fra74.cpd73.cpd116
set But263(53) .top263.fra74.cpd73.cpd102
set But263(54) .top263.fra74.cpd73.cpd117
set But263(55) .top263.fra74.cpd73.cpd103
set But263(56) .top263.fra74.cpd73.cpd118
set But263(57) .top263.fra74.cpd73.cpd104
set But263(58) .top263.fra74.cpd73.cpd119
set But263(59) .top263.fra74.cpd73.cpd105
set But263(60) .top263.fra74.cpd73.cpd120
set But263(61) .top263.fra74.cpd73.cpd106
set But263(62) .top263.fra74.cpd73.cpd121
set But263(63) .top263.fra74.cpd73.cpd122

set Lbl263(0) 0        
for {set i 0} {$i <= 110} {incr i} { set Lbl263($i) "" }

set Lbl263(1) .top263.fra74.cpd161.cpd75
set Lbl263(2) .top263.fra74.cpd161.cpd139
set Lbl263(3) .top263.fra74.cpd161.cpd167
set Lbl263(4) .top263.fra74.cpd161.cpd168
set Lbl263(5) .top263.fra74.cpd156.cpd83

set Lbl263(6) .top263.fra74.cpd161.cpd140
set Lbl263(7) .top263.fra74.cpd161.cpd141
set Lbl263(8) .top263.fra74.cpd161.cpd144
set Lbl263(9) .top263.fra74.cpd161.cpd76
set Lbl263(10) .top263.fra74.cpd156.cpd93

set Lbl263(11) .top263.fra74.cpd161.cpd125
set Lbl263(12) .top263.fra74.cpd161.cpd145
set Lbl263(13) .top263.fra74.cpd161.cpd147
set Lbl263(14) .top263.fra74.cpd161.cpd148
set Lbl263(15) .top263.fra74.cpd156.cpd103

set Lbl263(16) .top263.fra74.cpd161.cpd146
set Lbl263(17) .top263.fra74.cpd161.cpd169
set Lbl263(18) .top263.fra74.cpd161.cpd170
set Lbl263(19) .top263.fra74.cpd161.cpd82
set Lbl263(20) .top263.fra74.cpd156.cpd130

set Lbl263(21) .top263.fra74.cpd136.cpd75
set Lbl263(22) .top263.fra74.cpd136.cpd139
set Lbl263(23) .top263.fra74.cpd135.cpd77

set Lbl263(24) .top263.fra74.cpd136.cpd140
set Lbl263(25) .top263.fra74.cpd136.cpd76
set Lbl263(26) .top263.fra74.cpd135.cpd83

set Lbl263(27) .top263.fra74.cpd136.cpd124
set Lbl263(28) .top263.fra74.cpd136.cpd141
set Lbl263(29) .top263.fra74.cpd135.cpd89

set Lbl263(30) .top263.fra74.cpd136.cpd144
set Lbl263(31) .top263.fra74.cpd136.cpd80
set Lbl263(32) .top263.fra74.cpd135.cpd93

set Lbl263(33) .top263.fra74.cpd136.cpd125
set Lbl263(34) .top263.fra74.cpd136.cpd145
set Lbl263(35) .top263.fra74.cpd135.cpd97

set Lbl263(36) .top263.fra74.cpd136.cpd146
set Lbl263(37) .top263.fra74.cpd136.cpd82
set Lbl263(38) .top263.fra74.cpd135.cpd103

set Lbl263(39) .top263.fra74.cpd136.cpd126
set Lbl263(40) .top263.fra74.cpd136.cpd147
set Lbl263(41) .top263.fra74.cpd135.cpd105

set Lbl263(42) .top263.fra74.cpd136.cpd148
set Lbl263(43) .top263.fra74.cpd136.cpd84
set Lbl263(44) .top263.fra74.cpd135.cpd130

set Lbl263(45) .top263.fra74.fra73.cpd75
set Lbl263(46) .top263.fra74.cpd90.cpd75

set Lbl263(47) .top263.fra74.fra73.cpd76
set Lbl263(48) .top263.fra74.cpd90.cpd77

set Lbl263(49) .top263.fra74.fra73.cpd123
set Lbl263(50) .top263.fra74.cpd90.cpd79

set Lbl263(51) .top263.fra74.fra73.cpd78
set Lbl263(52) .top263.fra74.cpd90.cpd81

set Lbl263(53) .top263.fra74.fra73.cpd124
set Lbl263(54) .top263.fra74.cpd90.cpd83

set Lbl263(55) .top263.fra74.fra73.cpd80
set Lbl263(56) .top263.fra74.cpd90.cpd85

set Lbl263(57) .top263.fra74.fra73.cpd125
set Lbl263(58) .top263.fra74.cpd90.cpd87

set Lbl263(59) .top263.fra74.fra73.cpd82
set Lbl263(60) .top263.fra74.cpd90.cpd89

set Lbl263(61) .top263.fra74.fra73.cpd126
set Lbl263(62) .top263.fra74.cpd90.cpd93

set Lbl263(63) .top263.fra74.fra73.cpd84
set Lbl263(64) .top263.fra74.cpd90.cpd95

set Lbl263(65) .top263.fra74.fra73.cpd131
set Lbl263(66) .top263.fra74.cpd90.cpd97

set Lbl263(67) .top263.fra74.fra73.cpd86
set Lbl263(68) .top263.fra74.cpd90.cpd99

set Lbl263(69) .top263.fra74.fra73.cpd132
set Lbl263(70) .top263.fra74.cpd90.cpd101

set Lbl263(71) .top263.fra74.fra73.cpd88
set Lbl263(72) .top263.fra74.cpd90.cpd103

set Lbl263(73) .top263.fra74.fra73.cpd133
set Lbl263(74) .top263.fra74.cpd90.cpd105

set Lbl263(75) .top263.fra74.fra73.cpd134
set Lbl263(76) .top263.fra74.cpd90.cpd130

set Lbl263(77) .top263.fra74.cpd75.cpd128
set Lbl263(78) .top263.fra74.cpd75.cpd75

set Lbl263(79) .top263.fra74.cpd75.cpd76
set Lbl263(80) .top263.fra74.cpd75.cpd77

set Lbl263(81) .top263.fra74.cpd75.cpd78
set Lbl263(82) .top263.fra74.cpd75.cpd79

set Lbl263(83) .top263.fra74.cpd75.cpd80
set Lbl263(84) .top263.fra74.cpd75.cpd81

set Lbl263(85) .top263.fra74.cpd75.cpd82
set Lbl263(86) .top263.fra74.cpd75.cpd83

set Lbl263(87) .top263.fra74.cpd75.cpd84
set Lbl263(88) .top263.fra74.cpd75.cpd85

set Lbl263(89) .top263.fra74.cpd75.cpd86
set Lbl263(90) .top263.fra74.cpd75.cpd87

set Lbl263(91) .top263.fra74.cpd75.cpd88
set Lbl263(92) .top263.fra74.cpd75.cpd89

set Lbl263(93) .top263.fra74.cpd75.cpd92
set Lbl263(94) .top263.fra74.cpd75.cpd93

set Lbl263(95) .top263.fra74.cpd75.cpd94
set Lbl263(96) .top263.fra74.cpd75.cpd95

set Lbl263(97) .top263.fra74.cpd75.cpd96
set Lbl263(98) .top263.fra74.cpd75.cpd97

set Lbl263(99) .top263.fra74.cpd75.cpd98
set Lbl263(100) .top263.fra74.cpd75.cpd99

set Lbl263(101) .top263.fra74.cpd75.cpd100
set Lbl263(102) .top263.fra74.cpd75.cpd101

set Lbl263(103) .top263.fra74.cpd75.cpd102
set Lbl263(104) .top263.fra74.cpd75.cpd103

set Lbl263(105) .top263.fra74.cpd75.cpd104
set Lbl263(106) .top263.fra74.cpd75.cpd105

set Lbl263(107) .top263.fra74.cpd75.cpd106
set Lbl263(108) .top263.fra74.cpd75.cpd130
}
#############################################################################
## Procedure:  TreeInitStructure

proc ::TreeInitStructure {} {
global But263 Lbl263 TreeNodeType NumNodeActive
global ImageSymbolClass ImageSymbolNode ImageSymbolVide
global ImageSymbolHorz ImageSymbolVert ImageSymbolRightCorner
global ImageSymbolLeftCorner ImageSymbolRightDiag ImageSymbolLeftDiag


for {set i 4} {$i <= 63} {incr i} { 
    $But263($i) configure -image ImageSymbolVide
    }
 
for {set i 1} {$i <= 108} {incr i} { 
    $Lbl263($i) configure -image ImageSymbolVide
    }

$But263(2) configure -image ImageSymbolClass
$But263(3) configure -image ImageSymbolClass
set TreeNodeType(1) "node" 
set TreeNodeType(2) "class" 
set TreeNodeType(3) "class" 
for {set i 4} {$i <= 63} {incr i} { $But263($i) configure -state disable }

set NumNodeActive 0; TreeActiveNode $NumNodeActive
}
#############################################################################
## Procedure:  TreeCreateClass

proc ::TreeCreateClass {NumNode} {
global But263 Lbl263 TreeNodeType
global ImageSymbolClass ImageSymbolNode ImageSymbolVide
global ImageSymbolHorz ImageSymbolVert ImageSymbolRightCorner
global ImageSymbolLeftCorner ImageSymbolRightDiag ImageSymbolLeftDiag

$But263($NumNode) configure -image ImageSymbolClass
set TreeNodeType($NumNode) "class" 

if {$NumNode == 2} {
    TreeDisableBranch 2
    TreeDisableBranch 4
    TreeDisableBranch 5
    TreeDisableBranch 8
    TreeDisableBranch 9
    TreeDisableBranch 10
    TreeDisableBranch 11
    TreeDisableBranch 16
    TreeDisableBranch 17
    TreeDisableBranch 18
    TreeDisableBranch 19
    TreeDisableBranch 20
    TreeDisableBranch 21
    TreeDisableBranch 22
    TreeDisableBranch 23
    }
if {$NumNode == 3} {
    TreeDisableBranch 3
    TreeDisableBranch 6
    TreeDisableBranch 7
    TreeDisableBranch 12
    TreeDisableBranch 13
    TreeDisableBranch 14
    TreeDisableBranch 15
    TreeDisableBranch 24
    TreeDisableBranch 25
    TreeDisableBranch 26
    TreeDisableBranch 27
    TreeDisableBranch 28
    TreeDisableBranch 29
    TreeDisableBranch 30
    TreeDisableBranch 31
    }
if {$NumNode == 4} {
    TreeDisableBranch 4
    TreeDisableBranch 8
    TreeDisableBranch 9
    TreeDisableBranch 16
    TreeDisableBranch 17
    TreeDisableBranch 18
    TreeDisableBranch 19
    }
if {$NumNode == 5} {
    TreeDisableBranch 5
    TreeDisableBranch 10
    TreeDisableBranch 11
    TreeDisableBranch 20
    TreeDisableBranch 21
    TreeDisableBranch 22
    TreeDisableBranch 23
    }
if {$NumNode == 6} {
    TreeDisableBranch 6
    TreeDisableBranch 12
    TreeDisableBranch 13
    TreeDisableBranch 24
    TreeDisableBranch 25
    TreeDisableBranch 26
    TreeDisableBranch 27
    }
if {$NumNode == 7} {
    TreeDisableBranch 7
    TreeDisableBranch 14
    TreeDisableBranch 15
    TreeDisableBranch 28
    TreeDisableBranch 29
    TreeDisableBranch 30
    TreeDisableBranch 31
    }    
if {$NumNode == 8} {
    TreeDisableBranch 8
    TreeDisableBranch 16
    TreeDisableBranch 17
    }
if {$NumNode == 9} {
    TreeDisableBranch 9
    TreeDisableBranch 18
    TreeDisableBranch 19
    }
if {$NumNode == 10} {
    TreeDisableBranch 10
    TreeDisableBranch 20
    TreeDisableBranch 21
    }
if {$NumNode == 11} {
    TreeDisableBranch 11
    TreeDisableBranch 22
    TreeDisableBranch 23
    }
if {$NumNode == 12} {
    TreeDisableBranch 12
    TreeDisableBranch 24
    TreeDisableBranch 25
    }
if {$NumNode == 13} {
    TreeDisableBranch 13
    TreeDisableBranch 26
    TreeDisableBranch 27
    }
if {$NumNode == 14} {
    TreeDisableBranch 14
    TreeDisableBranch 28
    TreeDisableBranch 29
    }
if {$NumNode == 15} {
    TreeDisableBranch 15
    TreeDisableBranch 30
    TreeDisableBranch 31
    }
if {$NumNode == 16} {
    TreeDisableBranch 16
    }
if {$NumNode == 17} {
    TreeDisableBranch 17
    }
if {$NumNode == 18} {
    TreeDisableBranch 18
    }
if {$NumNode == 19} {
    TreeDisableBranch 19
    }
if {$NumNode == 20} {
    TreeDisableBranch 20
    }
if {$NumNode == 21} {
    TreeDisableBranch 21
    }
if {$NumNode == 22} {
    TreeDisableBranch 22
    }
if {$NumNode == 23} {
    TreeDisableBranch 23
    }
if {$NumNode == 24} {
    TreeDisableBranch 24
    }
if {$NumNode == 25} {
    TreeDisableBranch 25
    }
if {$NumNode == 26} {
    TreeDisableBranch 26
    }
if {$NumNode == 27} {
    TreeDisableBranch 27
    }
if {$NumNode == 28} {
    TreeDisableBranch 28
    }
if {$NumNode == 29} {
    TreeDisableBranch 29
    }
if {$NumNode == 30} {
    TreeDisableBranch 30
    }
if {$NumNode == 31} {
    TreeDisableBranch 31
    }
    
}
#############################################################################
## Procedure:  TreeDisableBranch

proc ::TreeDisableBranch {NumNode} {
global But263 Lbl263 TreeNodeType
global ImageSymbolClass ImageSymbolNode ImageSymbolVide
global ImageSymbolHorz ImageSymbolVert ImageSymbolRightCorner
global ImageSymbolLeftCorner ImageSymbolRightDiag ImageSymbolLeftDiag

if {$NumNode == 2} {
    $But263(4) configure -image ImageSymbolVide
    $But263(5) configure -image ImageSymbolVide
    set TreeNodeType(4) "XX"; set TreeNodeType(5) "XX"
    for {set i 1} {$i <= 10} {incr i} { $Lbl263($i) configure -image ImageSymbolVide }
    $But263(4) configure -state disable
    $But263(5) configure -state disable
    }
if {$NumNode == 3} {
    $But263(6) configure -image ImageSymbolVide
    $But263(7) configure -image ImageSymbolVide
    set TreeNodeType(6) "XX"; set TreeNodeType(7) "XX"
    for {set i 11} {$i <= 20} {incr i} { $Lbl263($i) configure -image ImageSymbolVide }
    $But263(6) configure -state disable
    $But263(7) configure -state disable
    }
if {$NumNode == 4} {
    $But263(8) configure -image ImageSymbolVide
    $But263(9) configure -image ImageSymbolVide
    set TreeNodeType(8) "XX"; set TreeNodeType(9) "XX"
    for {set i 21} {$i <= 26} {incr i} { $Lbl263($i) configure -image ImageSymbolVide }
    $But263(8) configure -state disable
    $But263(9) configure -state disable
    }
if {$NumNode == 5} {
    $But263(10) configure -image ImageSymbolVide
    $But263(11) configure -image ImageSymbolVide
    set TreeNodeType(10) "XX"; set TreeNodeType(11) "XX"
    for {set i 27} {$i <= 32} {incr i} { $Lbl263($i) configure -image ImageSymbolVide }
    $But263(10) configure -state disable
    $But263(11) configure -state disable
    }
if {$NumNode == 6} {
    $But263(12) configure -image ImageSymbolVide
    $But263(13) configure -image ImageSymbolVide
    set TreeNodeType(12) "XX"; set TreeNodeType(13) "XX"
    for {set i 33} {$i <= 38} {incr i} { $Lbl263($i) configure -image ImageSymbolVide }
    $But263(12) configure -state disable
    $But263(13) configure -state disable
    }
if {$NumNode == 7} {
    $But263(14) configure -image ImageSymbolVide
    $But263(15) configure -image ImageSymbolVide
    set TreeNodeType(14) "XX"; set TreeNodeType(15) "XX"
    for {set i 39} {$i <= 44} {incr i} { $Lbl263($i) configure -image ImageSymbolVide }
    $But263(14) configure -state disable
    $But263(15) configure -state disable
    }    
if {$NumNode == 8} {
    $But263(16) configure -image ImageSymbolVide
    $But263(17) configure -image ImageSymbolVide
    set TreeNodeType(16) "XX"; set TreeNodeType(17) "XX"
    for {set i 45} {$i <= 48} {incr i} { $Lbl263($i) configure -image ImageSymbolVide }
    $But263(16) configure -state disable
    $But263(17) configure -state disable
    }
if {$NumNode == 9} {
    $But263(18) configure -image ImageSymbolVide
    $But263(19) configure -image ImageSymbolVide
    set TreeNodeType(18) "XX"; set TreeNodeType(19) "XX"
    for {set i 49} {$i <= 52} {incr i} { $Lbl263($i) configure -image ImageSymbolVide }
    $But263(18) configure -state disable
    $But263(19) configure -state disable
    }
if {$NumNode == 10} {
    $But263(20) configure -image ImageSymbolVide
    $But263(21) configure -image ImageSymbolVide
    set TreeNodeType(20) "XX"; set TreeNodeType(21) "XX"
    for {set i 53} {$i <= 56} {incr i} { $Lbl263($i) configure -image ImageSymbolVide }
    $But263(20) configure -state disable
    $But263(21) configure -state disable
    }
if {$NumNode == 11} {
    $But263(22) configure -image ImageSymbolVide
    $But263(23) configure -image ImageSymbolVide
    set TreeNodeType(22) "XX"; set TreeNodeType(23) "XX"
    for {set i 57} {$i <= 60} {incr i} { $Lbl263($i) configure -image ImageSymbolVide }
    $But263(22) configure -state disable
    $But263(23) configure -state disable
    }
if {$NumNode == 12} {
    $But263(24) configure -image ImageSymbolVide
    $But263(25) configure -image ImageSymbolVide
    set TreeNodeType(24) "XX"; set TreeNodeType(25) "XX"
    for {set i 61} {$i <= 64} {incr i} { $Lbl263($i) configure -image ImageSymbolVide }
    $But263(24) configure -state disable
    $But263(25) configure -state disable
    }
if {$NumNode == 13} {
    $But263(26) configure -image ImageSymbolVide
    $But263(27) configure -image ImageSymbolVide
    set TreeNodeType(26) "XX"; set TreeNodeType(27) "XX"
    for {set i 65} {$i <= 68} {incr i} { $Lbl263($i) configure -image ImageSymbolVide }
    $But263(26) configure -state disable
    $But263(27) configure -state disable
    }
if {$NumNode == 14} {
    $But263(28) configure -image ImageSymbolVide
    $But263(29) configure -image ImageSymbolVide
    set TreeNodeType(28) "XX"; set TreeNodeType(29) "XX"
    for {set i 69} {$i <= 72} {incr i} { $Lbl263($i) configure -image ImageSymbolVide }
    $But263(28) configure -state disable
    $But263(29) configure -state disable
    }
if {$NumNode == 15} {
    $But263(30) configure -image ImageSymbolVide
    $But263(31) configure -image ImageSymbolVide
    set TreeNodeType(30) "XX"; set TreeNodeType(31) "XX"
    for {set i 73} {$i <= 76} {incr i} { $Lbl263($i) configure -image ImageSymbolVide }
    $But263(30) configure -state disable
    $But263(31) configure -state disable
    }
if {$NumNode == 16} {
    $But263(32) configure -image ImageSymbolVide
    $But263(33) configure -image ImageSymbolVide
    $But263(32) configure -state disable
    $But263(33) configure -state disable
    $Lbl263(77) configure -image ImageSymbolVide
    $Lbl263(78) configure -image ImageSymbolVide
    set TreeNodeType(32) "XX"; set TreeNodeType(33) "XX"
    }
if {$NumNode == 17} {
    $But263(34) configure -image ImageSymbolVide
    $But263(35) configure -image ImageSymbolVide
    $But263(34) configure -state disable
    $But263(35) configure -state disable
    $Lbl263(79) configure -image ImageSymbolVide
    $Lbl263(80) configure -image ImageSymbolVide
    set TreeNodeType(34) "XX"; set TreeNodeType(35) "XX"
    }
if {$NumNode == 18} {
    $But263(36) configure -image ImageSymbolVide
    $But263(37) configure -image ImageSymbolVide
    $But263(36) configure -state disable
    $But263(37) configure -state disable
    $Lbl263(81) configure -image ImageSymbolVide
    $Lbl263(82) configure -image ImageSymbolVide
    set TreeNodeType(36) "XX"; set TreeNodeType(37) "XX"
    }
if {$NumNode == 19} {
    $But263(38) configure -image ImageSymbolVide
    $But263(39) configure -image ImageSymbolVide
    $But263(38) configure -state disable
    $But263(39) configure -state disable
    $Lbl263(83) configure -image ImageSymbolVide
    $Lbl263(84) configure -image ImageSymbolVide
    set TreeNodeType(38) "XX"; set TreeNodeType(39) "XX"
    }
if {$NumNode == 20} {
    $But263(40) configure -image ImageSymbolVide
    $But263(41) configure -image ImageSymbolVide
    $But263(40) configure -state disable
    $But263(41) configure -state disable
    $Lbl263(85) configure -image ImageSymbolVide
    $Lbl263(86) configure -image ImageSymbolVide
    set TreeNodeType(40) "XX"; set TreeNodeType(41) "XX"
    }
if {$NumNode == 21} {
    $But263(42) configure -image ImageSymbolVide
    $But263(43) configure -image ImageSymbolVide
    $But263(42) configure -state disable
    $But263(43) configure -state disable
    $Lbl263(87) configure -image ImageSymbolVide
    $Lbl263(88) configure -image ImageSymbolVide
    set TreeNodeType(42) "XX"; set TreeNodeType(43) "XX"
   }
if {$NumNode == 22} {
    $But263(44) configure -image ImageSymbolVide
    $But263(45) configure -image ImageSymbolVide
    $But263(44) configure -state disable
    $But263(45) configure -state disable
    $Lbl263(89) configure -image ImageSymbolVide
    $Lbl263(90) configure -image ImageSymbolVide
    set TreeNodeType(44) "XX"; set TreeNodeType(45) "XX"
    }
if {$NumNode == 23} {
    $But263(46) configure -image ImageSymbolVide
    $But263(47) configure -image ImageSymbolVide
    $But263(46) configure -state disable
    $But263(47) configure -state disable
    $Lbl263(91) configure -image ImageSymbolVide
    $Lbl263(92) configure -image ImageSymbolVide
    set TreeNodeType(46) "XX"; set TreeNodeType(47) "XX"
    }
if {$NumNode == 24} {
    $But263(48) configure -image ImageSymbolVide
    $But263(49) configure -image ImageSymbolVide
    $But263(48) configure -state disable
    $But263(49) configure -state disable
    $Lbl263(93) configure -image ImageSymbolVide
    $Lbl263(94) configure -image ImageSymbolVide
    set TreeNodeType(48) "XX"; set TreeNodeType(49) "XX"
    }
if {$NumNode == 25} {
    $But263(50) configure -image ImageSymbolVide
    $But263(51) configure -image ImageSymbolVide
    $But263(50) configure -state disable
    $But263(51) configure -state disable
    $Lbl263(95) configure -image ImageSymbolVide
    $Lbl263(96) configure -image ImageSymbolVide
    set TreeNodeType(50) "XX"; set TreeNodeType(51) "XX"
    }
if {$NumNode == 26} {
    $But263(52) configure -image ImageSymbolVide
    $But263(53) configure -image ImageSymbolVide
    $But263(52) configure -state disable
    $But263(53) configure -state disable
    $Lbl263(97) configure -image ImageSymbolVide
    $Lbl263(98) configure -image ImageSymbolVide
    set TreeNodeType(52) "XX"; set TreeNodeType(53) "XX"
    }
if {$NumNode == 27} {
    $But263(54) configure -image ImageSymbolVide
    $But263(55) configure -image ImageSymbolVide
    $But263(54) configure -state disable
    $But263(55) configure -state disable
    $Lbl263(99) configure -image ImageSymbolVide
    $Lbl263(100) configure -image ImageSymbolVide
    set TreeNodeType(54) "XX"; set TreeNodeType(55) "XX"
    }
if {$NumNode == 28} {
    $But263(56) configure -image ImageSymbolVide
    $But263(57) configure -image ImageSymbolVide
    $But263(56) configure -state disable
    $But263(57) configure -state disable
    $Lbl263(101) configure -image ImageSymbolVide
    $Lbl263(102) configure -image ImageSymbolVide
    set TreeNodeType(56) "XX"; set TreeNodeType(57) "XX"
    }
if {$NumNode == 29} {
    $But263(58) configure -image ImageSymbolVide
    $But263(59) configure -image ImageSymbolVide
    $But263(58) configure -state disable
    $But263(59) configure -state disable
    $Lbl263(103) configure -image ImageSymbolVide
    $Lbl263(104) configure -image ImageSymbolVide
    set TreeNodeType(58) "XX"; set TreeNodeType(59) "XX"
    }
if {$NumNode == 30} {
    $But263(60) configure -image ImageSymbolVide
    $But263(61) configure -image ImageSymbolVide
    $But263(60) configure -state disable
    $But263(61) configure -state disable
    $Lbl263(105) configure -image ImageSymbolVide
    $Lbl263(106) configure -image ImageSymbolVide
    set TreeNodeType(60) "XX"; set TreeNodeType(61) "XX"
    }
if {$NumNode == 31} {
    $But263(62) configure -image ImageSymbolVide
    $But263(63) configure -image ImageSymbolVide
    $But263(62) configure -state disable
    $But263(63) configure -state disable
    $Lbl263(107) configure -image ImageSymbolVide
    $Lbl263(108) configure -image ImageSymbolVide
    set TreeNodeType(62) "XX"; set TreeNodeType(63) "XX"
    }
}
#############################################################################
## Procedure:  TreeCreateNode

proc ::TreeCreateNode {NumNode} {
global But263 Lbl263 TreeNodeType
global ImageSymbolClass ImageSymbolNode ImageSymbolVide
global ImageSymbolHorz ImageSymbolVert ImageSymbolRightCorner
global ImageSymbolLeftCorner ImageSymbolRightDiag ImageSymbolLeftDiag
    
$But263($NumNode) configure -image ImageSymbolNode
set TreeNodeType($NumNode) "node" 

TreeEnableBranch $NumNode
}
#############################################################################
## Procedure:  TreeEnableBranch

proc ::TreeEnableBranch {NumNode} {
global But263 Lbl263 TreeNodeType
global ImageSymbolClass ImageSymbolNode ImageSymbolVide
global ImageSymbolHorz ImageSymbolVert ImageSymbolRightCorner
global ImageSymbolLeftCorner ImageSymbolRightDiag ImageSymbolLeftDiag

if {$NumNode == 2} {
    $But263(4) configure -image ImageSymbolClass; $But263(5) configure -image ImageSymbolClass
    set TreeNodeType(4) "class"; set TreeNodeType(5) "class"
    $But263(4) configure -state normal; $But263(5) configure -state normal
    $Lbl263(1) configure -image ImageSymbolRightCorner
    $Lbl263(9) configure -image ImageSymbolLeftCorner
    $Lbl263(2) configure -image ImageSymbolHorz; $Lbl263(3) configure -image ImageSymbolHorz
    $Lbl263(4) configure -image ImageSymbolHorz; $Lbl263(6) configure -image ImageSymbolHorz
    $Lbl263(7) configure -image ImageSymbolHorz; $Lbl263(8) configure -image ImageSymbolHorz
    $Lbl263(5) configure -image ImageSymbolVert; $Lbl263(10) configure -image ImageSymbolVert
    }
if {$NumNode == 3} {
    $But263(6) configure -image ImageSymbolClass; $But263(7) configure -image ImageSymbolClass
    set TreeNodeType(6) "class"; set TreeNodeType(7) "class"
    $But263(6) configure -state normal; $But263(7) configure -state normal
    $Lbl263(11) configure -image ImageSymbolRightCorner
    $Lbl263(19) configure -image ImageSymbolLeftCorner
    $Lbl263(12) configure -image ImageSymbolHorz; $Lbl263(13) configure -image ImageSymbolHorz
    $Lbl263(14) configure -image ImageSymbolHorz; $Lbl263(16) configure -image ImageSymbolHorz
    $Lbl263(17) configure -image ImageSymbolHorz; $Lbl263(18) configure -image ImageSymbolHorz
    $Lbl263(15) configure -image ImageSymbolVert; $Lbl263(20) configure -image ImageSymbolVert
    }
if {$NumNode == 4} {
    $But263(8) configure -image ImageSymbolClass; $But263(9) configure -image ImageSymbolClass
    set TreeNodeType(8) "class"; set TreeNodeType(9) "class"
    $But263(8) configure -state normal; $But263(9) configure -state normal
    $Lbl263(21) configure -image ImageSymbolRightCorner
    $Lbl263(25) configure -image ImageSymbolLeftCorner
    $Lbl263(22) configure -image ImageSymbolHorz; $Lbl263(24) configure -image ImageSymbolHorz
    $Lbl263(23) configure -image ImageSymbolVert; $Lbl263(26) configure -image ImageSymbolVert
    }
if {$NumNode == 5} {
    $But263(10) configure -image ImageSymbolClass; $But263(11) configure -image ImageSymbolClass
    set TreeNodeType(10) "class"; set TreeNodeType(11) "class"
    $But263(10) configure -state normal; $But263(11) configure -state normal
    $Lbl263(27) configure -image ImageSymbolRightCorner
    $Lbl263(31) configure -image ImageSymbolLeftCorner
    $Lbl263(28) configure -image ImageSymbolHorz; $Lbl263(30) configure -image ImageSymbolHorz
    $Lbl263(29) configure -image ImageSymbolVert; $Lbl263(32) configure -image ImageSymbolVert
    }
if {$NumNode == 6} {
    $But263(12) configure -image ImageSymbolClass; $But263(13) configure -image ImageSymbolClass
    set TreeNodeType(12) "class"; set TreeNodeType(13) "class"
    $But263(12) configure -state normal; $But263(13) configure -state normal
    $Lbl263(33) configure -image ImageSymbolRightCorner
    $Lbl263(37) configure -image ImageSymbolLeftCorner
    $Lbl263(34) configure -image ImageSymbolHorz; $Lbl263(36) configure -image ImageSymbolHorz
    $Lbl263(35) configure -image ImageSymbolVert; $Lbl263(38) configure -image ImageSymbolVert
    }
if {$NumNode == 7} {
    $But263(14) configure -image ImageSymbolClass; $But263(15) configure -image ImageSymbolClass
    set TreeNodeType(14) "class"; set TreeNodeType(15) "class"
    $But263(14) configure -state normal; $But263(15) configure -state normal
    $Lbl263(39) configure -image ImageSymbolRightCorner
    $Lbl263(43) configure -image ImageSymbolLeftCorner
    $Lbl263(40) configure -image ImageSymbolHorz; $Lbl263(42) configure -image ImageSymbolHorz
    $Lbl263(41) configure -image ImageSymbolVert; $Lbl263(44) configure -image ImageSymbolVert
    }    
if {$NumNode == 8} {
    $But263(16) configure -image ImageSymbolClass; $But263(17) configure -image ImageSymbolClass
    set TreeNodeType(16) "class"; set TreeNodeType(17) "class"
    $But263(16) configure -state normal; $But263(17) configure -state normal
    $Lbl263(45) configure -image ImageSymbolRightCorner
    $Lbl263(47) configure -image ImageSymbolLeftCorner
    $Lbl263(46) configure -image ImageSymbolVert; $Lbl263(48) configure -image ImageSymbolVert
    }
if {$NumNode == 9} {
    $But263(18) configure -image ImageSymbolClass; $But263(19) configure -image ImageSymbolClass
    set TreeNodeType(18) "class"; set TreeNodeType(19) "class"
    $But263(18) configure -state normal; $But263(19) configure -state normal
    $Lbl263(49) configure -image ImageSymbolRightCorner
    $Lbl263(51) configure -image ImageSymbolLeftCorner
    $Lbl263(50) configure -image ImageSymbolVert; $Lbl263(52) configure -image ImageSymbolVert
    }
if {$NumNode == 10} {
    $But263(20) configure -image ImageSymbolClass; $But263(21) configure -image ImageSymbolClass
    set TreeNodeType(20) "class"; set TreeNodeType(21) "class"
    $But263(20) configure -state normal; $But263(21) configure -state normal
    $Lbl263(53) configure -image ImageSymbolRightCorner
    $Lbl263(55) configure -image ImageSymbolLeftCorner
    $Lbl263(54) configure -image ImageSymbolVert; $Lbl263(56) configure -image ImageSymbolVert
    }
if {$NumNode == 11} {
    $But263(22) configure -image ImageSymbolClass; $But263(23) configure -image ImageSymbolClass
    set TreeNodeType(22) "class"; set TreeNodeType(23) "class"
    $But263(22) configure -state normal; $But263(23) configure -state normal
    $Lbl263(57) configure -image ImageSymbolRightCorner
    $Lbl263(59) configure -image ImageSymbolLeftCorner
    $Lbl263(58) configure -image ImageSymbolVert; $Lbl263(60) configure -image ImageSymbolVert
    }
if {$NumNode == 12} {
    $But263(24) configure -image ImageSymbolClass; $But263(25) configure -image ImageSymbolClass
    set TreeNodeType(24) "class"; set TreeNodeType(25) "class"
    $But263(24) configure -state normal; $But263(25) configure -state normal
    $Lbl263(61) configure -image ImageSymbolRightCorner
    $Lbl263(63) configure -image ImageSymbolLeftCorner
    $Lbl263(62) configure -image ImageSymbolVert; $Lbl263(64) configure -image ImageSymbolVert
    }
if {$NumNode == 13} {
    $But263(26) configure -image ImageSymbolClass; $But263(27) configure -image ImageSymbolClass
    set TreeNodeType(26) "class"; set TreeNodeType(27) "class"
    $But263(26) configure -state normal; $But263(27) configure -state normal
    $Lbl263(65) configure -image ImageSymbolRightCorner
    $Lbl263(67) configure -image ImageSymbolLeftCorner
    $Lbl263(66) configure -image ImageSymbolVert; $Lbl263(68) configure -image ImageSymbolVert
    }
if {$NumNode == 14} {
    $But263(28) configure -image ImageSymbolClass; $But263(29) configure -image ImageSymbolClass
    set TreeNodeType(28) "class"; set TreeNodeType(29) "class"
    $But263(28) configure -state normal; $But263(29) configure -state normal
    $Lbl263(69) configure -image ImageSymbolRightCorner
    $Lbl263(71) configure -image ImageSymbolLeftCorner
    $Lbl263(70) configure -image ImageSymbolVert; $Lbl263(72) configure -image ImageSymbolVert
    }
if {$NumNode == 15} {
    $But263(30) configure -image ImageSymbolClass; $But263(31) configure -image ImageSymbolClass
    set TreeNodeType(30) "class"; set TreeNodeType(31) "class"
    $But263(30) configure -state normal; $But263(31) configure -state normal
    $Lbl263(73) configure -image ImageSymbolRightCorner
    $Lbl263(75) configure -image ImageSymbolLeftCorner
    $Lbl263(74) configure -image ImageSymbolVert; $Lbl263(76) configure -image ImageSymbolVert
    }
if {$NumNode == 16} {
    $But263(32) configure -image ImageSymbolClass; $But263(33) configure -image ImageSymbolClass
    set TreeNodeType(32) "class"; set TreeNodeType(33) "class"
    $But263(32) configure -state normal; $But263(33) configure -state normal
    $Lbl263(77) configure -image ImageSymbolRightDiag
    $Lbl263(78) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 17} {
    $But263(34) configure -image ImageSymbolClass; $But263(35) configure -image ImageSymbolClass
    set TreeNodeType(34) "class"; set TreeNodeType(35) "class"
    $But263(34) configure -state normal; $But263(35) configure -state normal
    $Lbl263(79) configure -image ImageSymbolRightDiag
    $Lbl263(80) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 18} {
    $But263(36) configure -image ImageSymbolClass; $But263(37) configure -image ImageSymbolClass
    set TreeNodeType(36) "class"; set TreeNodeType(37) "class"
    $But263(36) configure -state normal; $But263(37) configure -state normal
    $Lbl263(81) configure -image ImageSymbolRightDiag
    $Lbl263(82) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 19} {
    $But263(38) configure -image ImageSymbolClass; $But263(39) configure -image ImageSymbolClass
    set TreeNodeType(38) "class"; set TreeNodeType(39) "class"
    $But263(38) configure -state normal; $But263(39) configure -state normal
    $Lbl263(83) configure -image ImageSymbolRightDiag
    $Lbl263(84) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 20} {
    $But263(40) configure -image ImageSymbolClass; $But263(41) configure -image ImageSymbolClass
    set TreeNodeType(40) "class"; set TreeNodeType(41) "class"
    $But263(40) configure -state normal; $But263(41) configure -state normal
    $Lbl263(85) configure -image ImageSymbolRightDiag
    $Lbl263(86) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 21} {
    $But263(42) configure -image ImageSymbolClass; $But263(43) configure -image ImageSymbolClass
    set TreeNodeType(42) "class"; set TreeNodeType(43) "class"
    $But263(42) configure -state normal; $But263(43) configure -state normal
    $Lbl263(87) configure -image ImageSymbolRightDiag
    $Lbl263(88) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 22} {
    $But263(44) configure -image ImageSymbolClass; $But263(45) configure -image ImageSymbolClass
    set TreeNodeType(44) "class"; set TreeNodeType(45) "class"
    $But263(44) configure -state normal; $But263(45) configure -state normal
    $Lbl263(89) configure -image ImageSymbolRightDiag
    $Lbl263(90) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 23} {
    $But263(46) configure -image ImageSymbolClass; $But263(47) configure -image ImageSymbolClass
    set TreeNodeType(46) "class"; set TreeNodeType(47) "class"
    $But263(46) configure -state normal; $But263(47) configure -state normal
    $Lbl263(91) configure -image ImageSymbolRightDiag
    $Lbl263(92) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 24} {
    $But263(48) configure -image ImageSymbolClass; $But263(49) configure -image ImageSymbolClass
    set TreeNodeType(48) "class"; set TreeNodeType(49) "class"
    $But263(48) configure -state normal; $But263(49) configure -state normal
    $Lbl263(93) configure -image ImageSymbolRightDiag
    $Lbl263(94) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 25} {
    $But263(50) configure -image ImageSymbolClass; $But263(51) configure -image ImageSymbolClass
    set TreeNodeType(50) "class"; set TreeNodeType(51) "class"
    $But263(50) configure -state normal; $But263(51) configure -state normal
    $Lbl263(95) configure -image ImageSymbolRightDiag
    $Lbl263(96) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 26} {
    $But263(52) configure -image ImageSymbolClass; $But263(53) configure -image ImageSymbolClass
    set TreeNodeType(52) "class"; set TreeNodeType(53) "class"
    $But263(52) configure -state normal; $But263(53) configure -state normal
    $Lbl263(97) configure -image ImageSymbolRightDiag
    $Lbl263(98) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 27} {
    $But263(54) configure -image ImageSymbolClass; $But263(55) configure -image ImageSymbolClass
    set TreeNodeType(54) "class"; set TreeNodeType(55) "class"
    $But263(54) configure -state normal; $But263(55) configure -state normal
    $Lbl263(99) configure -image ImageSymbolRightDiag
    $Lbl263(100) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 28} {
    $But263(56) configure -image ImageSymbolClass; $But263(57) configure -image ImageSymbolClass
    set TreeNodeType(56) "class"; set TreeNodeType(57) "class"
    $But263(56) configure -state normal; $But263(57) configure -state normal
    $Lbl263(101) configure -image ImageSymbolRightDiag
    $Lbl263(102) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 29} {
    $But263(58) configure -image ImageSymbolClass; $But263(59) configure -image ImageSymbolClass
    set TreeNodeType(58) "class"; set TreeNodeType(59) "class"
    $But263(58) configure -state normal; $But263(59) configure -state normal
    $Lbl263(103) configure -image ImageSymbolRightDiag
    $Lbl263(104) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 30} {
    $But263(60) configure -image ImageSymbolClass; $But263(61) configure -image ImageSymbolClass
    set TreeNodeType(60) "class"; set TreeNodeType(61) "class"
    $But263(60) configure -state normal; $But263(61) configure -state normal
    $Lbl263(105) configure -image ImageSymbolRightDiag
    $Lbl263(106) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 31} {
    $But263(62) configure -image ImageSymbolClass; $But263(63) configure -image ImageSymbolClass
    set TreeNodeType(62) "class"; set TreeNodeType(63) "class"
    $But263(62) configure -state normal; $But263(63) configure -state normal
    $Lbl263(107) configure -image ImageSymbolRightDiag
    $Lbl263(108) configure -image ImageSymbolLeftDiag
    }
    
}
#############################################################################
## Procedure:  TreeNodeRAZ

proc ::TreeNodeRAZ {} {
global TreeNodeType TreeNodeClass
global TreeNodePara1 TreeNodePara2
global TreeNodeCoeff1 TreeNodeCoeff2
global TreeNodeCoeff3 TreeNodeOperator
global NodeCoeff1 NodeCoeff2 NodeCoeff3
global NodeClass NodeOperator NodeType
global TreePara1 TreePara2

set TreeNodeType(0) 0        
for {set i 0} {$i <= 64} {incr i} { set TreeNodeType($i) "XX" }
set TreeNodeClass(0) 0        
for {set i 0} {$i <= 64} {incr i} { set TreeNodeClass($i) "XX" }
set TreeNodePara1(0) 0        
for {set i 0} {$i <= 64} {incr i} { set TreeNodePara1($i) "XX" }
set TreeNodePara2(0) 0        
for {set i 0} {$i <= 64} {incr i} { set TreeNodePara2($i) "XX" }
set TreeNodeCoeff1(0) 0        
for {set i 0} {$i <= 64} {incr i} { set TreeNodeCoeff1($i) "XX" }
set TreeNodeCoeff2(0) 0        
for {set i 0} {$i <= 64} {incr i} { set TreeNodeCoeff2($i) "XX" }
set TreeNodeCoeff3(0) 0        
for {set i 0} {$i <= 64} {incr i} { set TreeNodeCoeff3($i) "XX" }
set TreeNodeOperator(0) 0        
for {set i 0} {$i <= 64} {incr i} { set TreeNodeOperator($i) "XX" }

set TreeNodeType(1) "node"        
set TreeNodeType(2) "class"        
set TreeNodeType(3) "class"    

set NodeType ""
set NodeCoeff1 ""; set NodeCoeff2 ""; set NodeCoeff3 ""
set NodeOperator ""; set NodeClass ""
set TreePara1 ""; set TreePara2 ""
.top263.fra118.cpd119.fra114.lab115 configure -state disable
.top263.fra118.cpd119.fra114.ent116 configure -state disable
.top263.fra118.fra73.cpd74 configure -state disable
.top263.fra118.fra73.cpd74.f.fra75.cpd76.lab122 configure -state disable
.top263.fra118.fra73.cpd74.f.fra75.cpd76.cpd74 configure -state disabled
.top263.fra118.fra73.cpd74.f.fra75.cpd77.lab122 configure -state disable
.top263.fra118.fra73.cpd74.f.fra75.cpd77.cpd75 configure -state disabled
.top263.fra118.fra73.cpd74.f.fra127.fra128.lab129 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.fra128.ent130 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.cpd131.lab129 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.cpd131.ent130 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.fra133.lab135 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.fra133.fra134.rad136 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.fra133.fra134.cpd137 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.cpd132.lab129 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.cpd132.ent130 configure -state disable
}
#############################################################################
## Procedure:  TreeActiveNode

proc ::TreeActiveNode {NumNode} {
global But263 NumNodeActive TreeNodeType
global ImageSymbolClass ImageSymbolNode ImageSymbolActive
global NodeCoeff1 NodeCoeff2 NodeCoeff3
global NodeClass NodeOperator NodeType
global TreePara1 TreePara2

if {$NumNode != 0 } { $But263($NumNode) configure -image ImageSymbolActive }

if {$TreeNodeType($NumNodeActive) == "node" } {$But263($NumNodeActive) configure -image ImageSymbolNode}
if {$TreeNodeType($NumNodeActive) == "class" } {$But263($NumNodeActive) configure -image ImageSymbolClass}
if {$NumNodeActive == $NumNode} {
    set NumNodeActive 0
    set NodeType ""
    set NodeCoeff1 ""; set NodeCoeff2 ""; set NodeCoeff3 ""
    set NodeOperator ""; set NodeClass ""
    set TreePara1 ""; set TreePara2 ""
    .top263.fra118.cpd119.fra114.lab115 configure -state disable
    .top263.fra118.cpd119.fra114.ent116 configure -state disable
    .top263.fra118.fra73.cpd74 configure -state disable
    .top263.fra118.fra73.cpd74.f.fra75.cpd76.lab122 configure -state disable
    .top263.fra118.fra73.cpd74.f.fra75.cpd76.cpd74 configure -state disabled
    .top263.fra118.fra73.cpd74.f.fra75.cpd77.lab122 configure -state disable
    .top263.fra118.fra73.cpd74.f.fra75.cpd77.cpd75 configure -state disabled
    .top263.fra118.fra73.cpd74.f.fra127.fra128.lab129 configure -state disable
    .top263.fra118.fra73.cpd74.f.fra127.fra128.ent130 configure -state disable
    .top263.fra118.fra73.cpd74.f.fra127.cpd131.lab129 configure -state disable
    .top263.fra118.fra73.cpd74.f.fra127.cpd131.ent130 configure -state disable
    .top263.fra118.fra73.cpd74.f.fra127.fra133.lab135 configure -state disable
    .top263.fra118.fra73.cpd74.f.fra127.fra133.fra134.rad136 configure -state disable
    .top263.fra118.fra73.cpd74.f.fra127.fra133.fra134.cpd137 configure -state disable
    .top263.fra118.fra73.cpd74.f.fra127.cpd132.lab129 configure -state disable
    .top263.fra118.fra73.cpd74.f.fra127.cpd132.ent130 configure -state disable
    } else {
    if {$TreeNodeType($NumNode) == "node" } { NodeON $NumNode }
    if {$TreeNodeType($NumNode) == "class" } { ClassON $NumNode }
    set NumNodeActive $NumNode
    }
}
#############################################################################
## Procedure:  NodeON

proc ::NodeON {NodeNumber} {
global TreeNodeType
global TreeNodePara1 TreeNodePara2
global TreeNodeCoeff1 TreeNodeCoeff2
global TreeNodeCoeff3 TreeNodeOperator
global TreeNodeClass
global NodeCoeff1 NodeCoeff2 NodeCoeff3
global NodeClass NodeOperator NodeType
global TreePara1 TreePara2 TreeInputParaLabel

set NodeType "node"
set TreeNodeType($NodeNumber) "node"
.top263.fra118.cpd119.fra114.lab115 configure -state disable; .top263.fra118.cpd119.fra114.ent116 configure -state disable
if {$TreeNodePara1($NodeNumber) != "XX"} { 
    set TreePara1 $TreeInputParaLabel($TreeNodePara1($NodeNumber))
    } else {
    set TreePara1 $TreeInputParaLabel(1)
    }
if {$TreeNodePara2($NodeNumber) != "XX"} { 
    set TreePara2 $TreeInputParaLabel($TreeNodePara2($NodeNumber))
    } else {
    set TreePara2 $TreeInputParaLabel(1)
    }
if {$TreeNodeCoeff1($NodeNumber) != "XX"} { set NodeCoeff1 $TreeNodeCoeff1($NodeNumber) } else { set NodeCoeff1 "?" } 
if {$TreeNodeCoeff2($NodeNumber) != "XX"} { set NodeCoeff2 $TreeNodeCoeff2($NodeNumber) } else { set NodeCoeff2 "?" }
if {$TreeNodeCoeff3($NodeNumber) != "XX"} { set NodeCoeff3 $TreeNodeCoeff3($NodeNumber) } else { set NodeCoeff3 "?" }
if {$TreeNodeOperator($NodeNumber) != "XX"} { set NodeOperator $TreeNodeOperator($NodeNumber) } else { set NodeOperator "inf" }
set NodeClass ""; set TreeNodeClass($NodeNumber) "XX"

.top263.fra118.fra73.cpd74 configure -state normal
.top263.fra118.fra73.cpd74.f.fra75.cpd76.lab122 configure -state normal
.top263.fra118.fra73.cpd74.f.fra75.cpd76.cpd74 configure -state normal
.top263.fra118.fra73.cpd74.f.fra75.cpd77.lab122 configure -state normal
.top263.fra118.fra73.cpd74.f.fra75.cpd77.cpd75 configure -state normal
.top263.fra118.fra73.cpd74.f.fra127.fra128.lab129 configure -state normal
.top263.fra118.fra73.cpd74.f.fra127.fra128.ent130 configure -state normal
.top263.fra118.fra73.cpd74.f.fra127.cpd131.lab129 configure -state normal
.top263.fra118.fra73.cpd74.f.fra127.cpd131.ent130 configure -state normal
.top263.fra118.fra73.cpd74.f.fra127.fra133.lab135 configure -state normal
.top263.fra118.fra73.cpd74.f.fra127.fra133.fra134.rad136 configure -state normal
.top263.fra118.fra73.cpd74.f.fra127.fra133.fra134.cpd137 configure -state normal
.top263.fra118.fra73.cpd74.f.fra127.cpd132.lab129 configure -state normal
.top263.fra118.fra73.cpd74.f.fra127.cpd132.ent130 configure -state normal
}
#############################################################################
## Procedure:  ClassON

proc ::ClassON {NodeNumber} {
global TreeNodeType
global TreeNodePara1 TreeNodePara2
global TreeNodeCoeff1 TreeNodeCoeff2
global TreeNodeCoeff3 TreeNodeOperator
global TreeNodeClass
global NodeCoeff1 NodeCoeff2 NodeCoeff3
global NodeClass NodeOperator NodeType
global TreePara1 TreePara2

set NodeType "class"
set TreeNodeType($NodeNumber) "class"
.top263.fra118.cpd119.fra114.lab115 configure -state normal; .top263.fra118.cpd119.fra114.ent116 configure -state normal
set TreeNodePara1($NodeNumber) "XX"
set TreeNodePara2($NodeNumber) "XX"
set TreeNodeCoeff1($NodeNumber) "XX"
set TreeNodeCoeff2($NodeNumber) "XX"
set TreeNodeCoeff3($NodeNumber) "XX"
set TreeNodeOperator($NodeNumber) "XX"
set NodeCoeff1 ""; set NodeCoeff2 ""; set NodeCoeff3 ""; set NodeOperator ""
set TreePara1 ""; set TreePara2 ""
if {$TreeNodeClass($NodeNumber) != "XX"} { set NodeClass $TreeNodeClass($NodeNumber) } else { set NodeClass "?" }

.top263.fra118.fra73.cpd74 configure -state disable
.top263.fra118.fra73.cpd74.f.fra75.cpd76.lab122 configure -state disable
.top263.fra118.fra73.cpd74.f.fra75.cpd76.cpd74 configure -state disabled
.top263.fra118.fra73.cpd74.f.fra75.cpd77.lab122 configure -state disable
.top263.fra118.fra73.cpd74.f.fra75.cpd77.cpd75 configure -state disabled
.top263.fra118.fra73.cpd74.f.fra127.fra128.lab129 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.fra128.ent130 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.cpd131.lab129 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.cpd131.ent130 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.fra133.lab135 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.fra133.fra134.rad136 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.fra133.fra134.cpd137 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.cpd132.lab129 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.cpd132.ent130 configure -state disable
}
#############################################################################
## Procedure:  TreeConstructStructure

proc ::TreeConstructStructure {} {
global But263 Lbl263 TreeNodeType NumNodeActive
global ImageSymbolClass ImageSymbolNode ImageSymbolVide
global ImageSymbolHorz ImageSymbolVert ImageSymbolRightCorner
global ImageSymbolLeftCorner ImageSymbolRightDiag ImageSymbolLeftDiag
global NodeCoeff1 NodeCoeff2 NodeCoeff3
global NodeClass NodeOperator NodeType
global TreePara1 TreePara2

for {set i 1} {$i <= 63} {incr i} { $But263($i) configure -image ImageSymbolVide }
for {set i 1} {$i <= 108} {incr i} { $Lbl263($i) configure -image ImageSymbolVide }
for {set i 4} {$i <= 63} {incr i} { $But263($i) configure -state disable }

$But263(1) configure -image ImageSymbolNode
$But263(2) configure -image ImageSymbolClass
$But263(3) configure -image ImageSymbolClass

for {set i 2} {$i < 32} {incr i} {

if {$TreeNodeType($i) == "node"} { 
set NumNode $i
$But263($NumNode) configure -image ImageSymbolNode
if {$NumNode == 2} {
    $But263(4) configure -image ImageSymbolClass; $But263(5) configure -image ImageSymbolClass
    $But263(4) configure -state normal; $But263(5) configure -state normal
    $Lbl263(1) configure -image ImageSymbolRightCorner
    $Lbl263(9) configure -image ImageSymbolLeftCorner
    $Lbl263(2) configure -image ImageSymbolHorz; $Lbl263(3) configure -image ImageSymbolHorz
    $Lbl263(4) configure -image ImageSymbolHorz; $Lbl263(6) configure -image ImageSymbolHorz
    $Lbl263(7) configure -image ImageSymbolHorz; $Lbl263(8) configure -image ImageSymbolHorz
    $Lbl263(5) configure -image ImageSymbolVert; $Lbl263(10) configure -image ImageSymbolVert
    }
if {$NumNode == 3} {
    $But263(6) configure -image ImageSymbolClass; $But263(7) configure -image ImageSymbolClass
    $But263(6) configure -state normal; $But263(7) configure -state normal
    $Lbl263(11) configure -image ImageSymbolRightCorner
    $Lbl263(19) configure -image ImageSymbolLeftCorner
    $Lbl263(12) configure -image ImageSymbolHorz; $Lbl263(13) configure -image ImageSymbolHorz
    $Lbl263(14) configure -image ImageSymbolHorz; $Lbl263(16) configure -image ImageSymbolHorz
    $Lbl263(17) configure -image ImageSymbolHorz; $Lbl263(18) configure -image ImageSymbolHorz
    $Lbl263(15) configure -image ImageSymbolVert; $Lbl263(20) configure -image ImageSymbolVert
    }
if {$NumNode == 4} {
    $But263(8) configure -image ImageSymbolClass; $But263(9) configure -image ImageSymbolClass
    $But263(8) configure -state normal; $But263(9) configure -state normal
    $Lbl263(21) configure -image ImageSymbolRightCorner
    $Lbl263(25) configure -image ImageSymbolLeftCorner
    $Lbl263(22) configure -image ImageSymbolHorz; $Lbl263(24) configure -image ImageSymbolHorz
    $Lbl263(23) configure -image ImageSymbolVert; $Lbl263(26) configure -image ImageSymbolVert
    }
if {$NumNode == 5} {
    $But263(10) configure -image ImageSymbolClass; $But263(11) configure -image ImageSymbolClass
    $But263(10) configure -state normal; $But263(11) configure -state normal
    $Lbl263(27) configure -image ImageSymbolRightCorner
    $Lbl263(31) configure -image ImageSymbolLeftCorner
    $Lbl263(28) configure -image ImageSymbolHorz; $Lbl263(30) configure -image ImageSymbolHorz
    $Lbl263(29) configure -image ImageSymbolVert; $Lbl263(32) configure -image ImageSymbolVert
    }
if {$NumNode == 6} {
    $But263(12) configure -image ImageSymbolClass; $But263(13) configure -image ImageSymbolClass
    $But263(12) configure -state normal; $But263(13) configure -state normal
    $Lbl263(33) configure -image ImageSymbolRightCorner
    $Lbl263(37) configure -image ImageSymbolLeftCorner
    $Lbl263(34) configure -image ImageSymbolHorz; $Lbl263(36) configure -image ImageSymbolHorz
    $Lbl263(35) configure -image ImageSymbolVert; $Lbl263(38) configure -image ImageSymbolVert
    }
if {$NumNode == 7} {
    $But263(14) configure -image ImageSymbolClass; $But263(15) configure -image ImageSymbolClass
    $But263(14) configure -state normal; $But263(15) configure -state normal
    $Lbl263(39) configure -image ImageSymbolRightCorner
    $Lbl263(43) configure -image ImageSymbolLeftCorner
    $Lbl263(40) configure -image ImageSymbolHorz; $Lbl263(42) configure -image ImageSymbolHorz
    $Lbl263(41) configure -image ImageSymbolVert; $Lbl263(44) configure -image ImageSymbolVert
    }    
if {$NumNode == 8} {
    $But263(16) configure -image ImageSymbolClass; $But263(17) configure -image ImageSymbolClass
    $But263(16) configure -state normal; $But263(17) configure -state normal
    $Lbl263(45) configure -image ImageSymbolRightCorner
    $Lbl263(47) configure -image ImageSymbolLeftCorner
    $Lbl263(46) configure -image ImageSymbolVert; $Lbl263(48) configure -image ImageSymbolVert
    }
if {$NumNode == 9} {
    $But263(18) configure -image ImageSymbolClass; $But263(19) configure -image ImageSymbolClass
    $But263(18) configure -state normal; $But263(19) configure -state normal
    $Lbl263(49) configure -image ImageSymbolRightCorner
    $Lbl263(51) configure -image ImageSymbolLeftCorner
    $Lbl263(50) configure -image ImageSymbolVert; $Lbl263(52) configure -image ImageSymbolVert
    }
if {$NumNode == 10} {
    $But263(20) configure -image ImageSymbolClass; $But263(21) configure -image ImageSymbolClass
    $But263(20) configure -state normal; $But263(21) configure -state normal
    $Lbl263(53) configure -image ImageSymbolRightCorner
    $Lbl263(55) configure -image ImageSymbolLeftCorner
    $Lbl263(54) configure -image ImageSymbolVert; $Lbl263(56) configure -image ImageSymbolVert
    }
if {$NumNode == 11} {
    $But263(22) configure -image ImageSymbolClass; $But263(23) configure -image ImageSymbolClass
    $But263(22) configure -state normal; $But263(23) configure -state normal
    $Lbl263(57) configure -image ImageSymbolRightCorner
    $Lbl263(59) configure -image ImageSymbolLeftCorner
    $Lbl263(58) configure -image ImageSymbolVert; $Lbl263(60) configure -image ImageSymbolVert
    }
if {$NumNode == 12} {
    $But263(24) configure -image ImageSymbolClass; $But263(25) configure -image ImageSymbolClass
    $But263(24) configure -state normal; $But263(25) configure -state normal
    $Lbl263(61) configure -image ImageSymbolRightCorner
    $Lbl263(63) configure -image ImageSymbolLeftCorner
    $Lbl263(62) configure -image ImageSymbolVert; $Lbl263(64) configure -image ImageSymbolVert
    }
if {$NumNode == 13} {
    $But263(26) configure -image ImageSymbolClass; $But263(27) configure -image ImageSymbolClass
    $But263(26) configure -state normal; $But263(27) configure -state normal
    $Lbl263(65) configure -image ImageSymbolRightCorner
    $Lbl263(67) configure -image ImageSymbolLeftCorner
    $Lbl263(66) configure -image ImageSymbolVert; $Lbl263(68) configure -image ImageSymbolVert
    }
if {$NumNode == 14} {
    $But263(28) configure -image ImageSymbolClass; $But263(29) configure -image ImageSymbolClass
    $But263(28) configure -state normal; $But263(29) configure -state normal
    $Lbl263(69) configure -image ImageSymbolRightCorner
    $Lbl263(71) configure -image ImageSymbolLeftCorner
    $Lbl263(70) configure -image ImageSymbolVert; $Lbl263(72) configure -image ImageSymbolVert
    }
if {$NumNode == 15} {
    $But263(30) configure -image ImageSymbolClass; $But263(31) configure -image ImageSymbolClass
    $But263(30) configure -state normal; $But263(31) configure -state normal
    $Lbl263(73) configure -image ImageSymbolRightCorner
    $Lbl263(75) configure -image ImageSymbolLeftCorner
    $Lbl263(74) configure -image ImageSymbolVert; $Lbl263(76) configure -image ImageSymbolVert
    }
if {$NumNode == 16} {
    $But263(32) configure -image ImageSymbolClass; $But263(33) configure -image ImageSymbolClass
    $But263(32) configure -state normal; $But263(33) configure -state normal
    $Lbl263(77) configure -image ImageSymbolRightDiag
    $Lbl263(78) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 17} {
    $But263(34) configure -image ImageSymbolClass; $But263(35) configure -image ImageSymbolClass
    $But263(34) configure -state normal; $But263(35) configure -state normal
    $Lbl263(79) configure -image ImageSymbolRightDiag
    $Lbl263(80) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 18} {
    $But263(36) configure -image ImageSymbolClass; $But263(37) configure -image ImageSymbolClass
    $But263(36) configure -state normal; $But263(37) configure -state normal
    $Lbl263(81) configure -image ImageSymbolRightDiag
    $Lbl263(82) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 19} {
    $But263(38) configure -image ImageSymbolClass; $But263(39) configure -image ImageSymbolClass
    $But263(38) configure -state normal; $But263(39) configure -state normal
    $Lbl263(83) configure -image ImageSymbolRightDiag
    $Lbl263(84) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 20} {
    $But263(40) configure -image ImageSymbolClass; $But263(41) configure -image ImageSymbolClass
    $But263(40) configure -state normal; $But263(41) configure -state normal
    $Lbl263(85) configure -image ImageSymbolRightDiag
    $Lbl263(86) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 21} {
    $But263(42) configure -image ImageSymbolClass; $But263(43) configure -image ImageSymbolClass
    $But263(42) configure -state normal; $But263(43) configure -state normal
    $Lbl263(87) configure -image ImageSymbolRightDiag
    $Lbl263(88) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 22} {
    $But263(44) configure -image ImageSymbolClass; $But263(45) configure -image ImageSymbolClass
    $But263(44) configure -state normal; $But263(45) configure -state normal
    $Lbl263(89) configure -image ImageSymbolRightDiag
    $Lbl263(90) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 23} {
    $But263(46) configure -image ImageSymbolClass; $But263(47) configure -image ImageSymbolClass
    $But263(46) configure -state normal; $But263(47) configure -state normal
    $Lbl263(91) configure -image ImageSymbolRightDiag
    $Lbl263(92) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 24} {
    $But263(48) configure -image ImageSymbolClass; $But263(49) configure -image ImageSymbolClass
    $But263(48) configure -state normal; $But263(49) configure -state normal
    $Lbl263(93) configure -image ImageSymbolRightDiag
    $Lbl263(94) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 25} {
    $But263(50) configure -image ImageSymbolClass; $But263(51) configure -image ImageSymbolClass
    $But263(50) configure -state normal; $But263(51) configure -state normal
    $Lbl263(95) configure -image ImageSymbolRightDiag
    $Lbl263(96) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 26} {
    $But263(52) configure -image ImageSymbolClass; $But263(53) configure -image ImageSymbolClass
    $But263(52) configure -state normal; $But263(53) configure -state normal
    $Lbl263(97) configure -image ImageSymbolRightDiag
    $Lbl263(98) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 27} {
    $But263(54) configure -image ImageSymbolClass; $But263(55) configure -image ImageSymbolClass
    $But263(54) configure -state normal; $But263(55) configure -state normal
    $Lbl263(99) configure -image ImageSymbolRightDiag
    $Lbl263(100) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 28} {
    $But263(56) configure -image ImageSymbolClass; $But263(57) configure -image ImageSymbolClass
    $But263(56) configure -state normal; $But263(57) configure -state normal
    $Lbl263(101) configure -image ImageSymbolRightDiag
    $Lbl263(102) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 29} {
    $But263(58) configure -image ImageSymbolClass; $But263(59) configure -image ImageSymbolClass
    $But263(58) configure -state normal; $But263(59) configure -state normal
    $Lbl263(103) configure -image ImageSymbolRightDiag
    $Lbl263(104) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 30} {
    $But263(60) configure -image ImageSymbolClass; $But263(61) configure -image ImageSymbolClass
    $But263(60) configure -state normal; $But263(61) configure -state normal
    $Lbl263(105) configure -image ImageSymbolRightDiag
    $Lbl263(106) configure -image ImageSymbolLeftDiag
    }
if {$NumNode == 31} {
    $But263(62) configure -image ImageSymbolClass; $But263(63) configure -image ImageSymbolClass
    $But263(62) configure -state normal; $But263(63) configure -state normal
    $Lbl263(107) configure -image ImageSymbolRightDiag
    $Lbl263(108) configure -image ImageSymbolLeftDiag
    }
}
}

set NumNodeActive 0; TreeActiveNode $NumNodeActive

set NodeType ""
set NodeCoeff1 ""; set NodeCoeff2 ""; set NodeCoeff3 ""
set NodeOperator ""; set NodeClass ""
set TreePara1 ""; set TreePara2 ""
.top263.fra118.cpd119.fra114.lab115 configure -state disable
.top263.fra118.cpd119.fra114.ent116 configure -state disable
.top263.fra118.fra73.cpd74 configure -state disable
.top263.fra118.fra73.cpd74.f.fra75.cpd76.lab122 configure -state disable
.top263.fra118.fra73.cpd74.f.fra75.cpd76.cpd74 configure -state disabled
.top263.fra118.fra73.cpd74.f.fra75.cpd77.lab122 configure -state disable
.top263.fra118.fra73.cpd74.f.fra75.cpd77.cpd75 configure -state disabled
.top263.fra118.fra73.cpd74.f.fra127.fra128.lab129 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.fra128.ent130 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.cpd131.lab129 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.cpd131.ent130 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.fra133.lab135 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.fra133.fra134.rad136 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.fra133.fra134.cpd137 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.cpd132.lab129 configure -state disable
.top263.fra118.fra73.cpd74.f.fra127.cpd132.ent130 configure -state disable
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

proc vTclWindow.top263 {base} {
    if {$base == ""} {
        set base .top263
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
    wm geometry $top 700x430+20+98; update
    wm maxsize $top 1604 1185
    wm minsize $top 104 1
    wm overrideredirect $top 0
    wm resizable $top 1 1
    wm title $top "Hierarchical Classification : Tree Structure Definition"
    vTcl:DefineAlias "$top" "Toplevel263" vTcl:Toplevel:WidgetProc "" 1
    bindtags $top "$top Toplevel all _TopLevel"
    vTcl:FireEvent $top <<Create>>
    wm protocol $top WM_DELETE_WINDOW "vTcl:FireEvent $top <<>>"

    frame $top.fra74 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra74" "Frame1" vTcl:WidgetProc "Toplevel263" 1
    set site_3_0 $top.fra74
    frame $site_3_0.fra175 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra175" "Frame2" vTcl:WidgetProc "Toplevel263" 1
    set site_4_0 $site_3_0.fra175
    label $site_4_0.lab176 \
        -borderwidth 0 
    vTcl:DefineAlias "$site_4_0.lab176" "Label1" vTcl:WidgetProc "Toplevel263" 1
    pack $site_4_0.lab176 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    frame $site_3_0.cpd172 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd172" "Frame11" vTcl:WidgetProc "Toplevel263" 1
    set site_4_0 $site_3_0.cpd172
    label $site_4_0.cpd138 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd138" "Label211" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd163 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd163" "Label227" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd164 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd164" "Label237" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd129 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd129" "Label238" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd77 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd77" "Label247" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd142 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd142" "Label249" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd87 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd87" "Label252" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd165 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd165" "Label253" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd125 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd125" "Label254" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd168 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd168" "Label242" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd167 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd167" "Label241" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd139 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd139" "Label240" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd145 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd145" "Label255" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd147 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd147" "Label256" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd173 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd173" "Label246" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd148 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd148" "Label257" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd113 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 1; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd113" "Button263_1" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd146 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd146" "Label258" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd140 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd140" "Label243" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd141 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd141" "Label244" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd144 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd144" "Label245" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd169 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd169" "Label259" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd174 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd174" "Label266" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd170 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd170" "Label260" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd82 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd82" "Label261" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd89 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd89" "Label262" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd79 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd79" "Label248" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd81 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd81" "Label250" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd85 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd85" "Label251" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd83 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd83" "Label263" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd149 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd149" "Label264" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd166 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd166" "Label265" vTcl:WidgetProc "Toplevel263" 1
    pack $site_4_0.cpd138 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd163 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd164 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd129 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd142 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd87 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd165 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd125 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd168 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd167 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd139 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd145 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd147 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd173 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd148 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd113 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 6 -side left 
    pack $site_4_0.cpd146 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd140 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd141 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd144 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd169 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd174 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd170 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd89 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd149 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd166 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd171 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd171" "Frame10" vTcl:WidgetProc "Toplevel263" 1
    set site_4_0 $site_3_0.cpd171
    label $site_4_0.cpd128 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd128" "Label185" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd78 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd78" "Label188" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd80 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd80" "Label199" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd82 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd82" "Label202" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd84 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd84" "Label212" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd86 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd86" "Label213" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd157 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd157" "Label215" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd143 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd143" "Label217" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd93 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd93" "Label219" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd94 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd94" "Label218" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd88 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd88" "Label214" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd96 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd96" "Label220" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd98 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd98" "Label221" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd100 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd100" "Label222" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd158 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd158" "Label223" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd150 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd150" "Label224" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd102 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd102" "Label225" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd92 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd92" "Label216" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd152 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd152" "Label226" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd104 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd104" "Label228" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd151 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd151" "Label229" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd153 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd153" "Label230" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd154 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd154" "Label233" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd155 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd155" "Label234" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd130 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd130" "Label235" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd106 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd106" "Label232" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd160 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd160" "Label231" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd159 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd159" "Label236" vTcl:WidgetProc "Toplevel263" 1
    pack $site_4_0.cpd128 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd157 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd143 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd94 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd88 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd96 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd100 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd158 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd150 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd102 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd152 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd104 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd151 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd153 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd154 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd155 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd130 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd106 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd160 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd159 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd161 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd161" "Frame9" vTcl:WidgetProc "Toplevel263" 1
    set site_4_0 $site_3_0.cpd161
    label $site_4_0.cpd138 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd138" "Label156" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd163 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd163" "Label203" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd164 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd164" "Label204" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd129 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd129" "Label101" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd75 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd75" "Label263_1" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd139 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd139" "Label263_2" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd167 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd167" "Label263_3" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd168 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd168" "Label263_4" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd107 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 2; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd107" "Button263_2" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd140 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd140" "Label263_6" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd141 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd141" "Label263_7" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd144 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd144" "Label263_8" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd76 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd76" "Label263_9" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd77 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd77" "Label182" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd79 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd79" "Label183" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd142 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd142" "Label184" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd81 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd81" "Label189" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd85 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd85" "Label190" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd87 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd87" "Label191" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd165 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd165" "Label205" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd125 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd125" "Label263_11" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd145 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd145" "Label263_12" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd147 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd147" "Label263_13" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd148 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd148" "Label263_14" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd113 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 3; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd113" "Button263_3" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd146 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd146" "Label263_16" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd169 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd169" "Label263_17" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd170 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd170" "Label263_18" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd82 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd82" "Label263_19" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd89 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd89" "Label196" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd83 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd83" "Label197" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd149 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd149" "Label198" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd166 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd166" "Label206" vTcl:WidgetProc "Toplevel263" 1
    pack $site_4_0.cpd138 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd163 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd164 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd129 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd139 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd167 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd168 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd107 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_4_0.cpd140 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd141 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd144 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd142 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd87 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd165 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd125 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd145 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd147 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd148 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd113 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_4_0.cpd146 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd169 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd170 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd89 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd149 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd166 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd156 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd156" "Frame8" vTcl:WidgetProc "Toplevel263" 1
    set site_4_0 $site_3_0.cpd156
    label $site_4_0.cpd128 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd128" "Label99" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd78 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd78" "Label111" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd80 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd80" "Label113" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd82 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd82" "Label151" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd83 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd83" "Label263_5" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd84 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd84" "Label153" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd86 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd86" "Label154" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd88 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd88" "Label155" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd157 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd157" "Label177" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd92 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd92" "Label157" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd143 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd143" "Label158" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd94 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd94" "Label159" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd93 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd93" "Label263_10" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd96 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd96" "Label161" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd98 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd98" "Label162" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd100 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd100" "Label163" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd158 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd158" "Label178" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd150 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd150" "Label165" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd102 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd102" "Label166" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd152 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd152" "Label167" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd103 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd103" "Label263_15" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd104 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd104" "Label169" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd151 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd151" "Label170" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd153 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd153" "Label171" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd160 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd160" "Label180" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd106 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd106" "Label173" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd154 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd154" "Label174" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd155 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd155" "Label175" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd130 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd130" "Label263_20" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd159 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd159" "Label179" vTcl:WidgetProc "Toplevel263" 1
    pack $site_4_0.cpd128 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd88 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd157 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd143 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd94 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd96 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd100 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd158 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd150 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd102 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd152 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd103 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd104 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd151 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd153 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd160 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd106 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd154 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd155 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd130 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd159 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd136 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd136" "Frame7" vTcl:WidgetProc "Toplevel263" 1
    set site_4_0 $site_3_0.cpd136
    label $site_4_0.cpd138 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd138" "Label141" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd129 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd129" "Label89" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd75 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd75" "Label263_21" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd139 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd139" "Label263_22" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd107 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 4; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd107" "Button263_4" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd140 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd140" "Label263_24" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd76 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd76" "Label263_25" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd77 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd77" "Label120" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd79 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd79" "Label123" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd142 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd142" "Label121" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd124 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd124" "Label263_27" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd141 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd141" "Label263_28" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd111 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 5; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd111" "Button263_5" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd144 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd144" "Label263_30" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd80 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd80" "Label263_31" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd81 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd81" "Label126" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd85 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd85" "Label132" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd87 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd87" "Label135" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd125 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd125" "Label263_33" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd145 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd145" "Label263_34" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd113 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 6; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd113" "Button263_6" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd146 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd146" "Label263_36" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd82 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd82" "Label263_37" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd89 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd89" "Label138" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd83 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd83" "Label129" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd149 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd149" "Label139" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd126 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd126" "Label263_39" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd147 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd147" "Label263_40" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd115 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 7; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd115" "Button263_7" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd148 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeHorzLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd148" "Label263_42" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd84 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd84" "Label263_43" vTcl:WidgetProc "Toplevel263" 1
    pack $site_4_0.cpd138 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd129 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd139 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd107 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd140 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd142 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd124 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd141 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd111 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd144 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd87 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd125 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd145 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd113 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd146 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd89 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd149 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd126 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd147 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd115 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd148 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd135 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd135" "Frame6" vTcl:WidgetProc "Toplevel263" 1
    set site_4_0 $site_3_0.cpd135
    label $site_4_0.cpd128 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd128" "Label88" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd76 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd76" "Label90" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd77 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd77" "Label263_23" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd78 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd78" "Label92" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd80 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd80" "Label94" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd82 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd82" "Label96" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd83 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd83" "Label263_26" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd84 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd84" "Label98" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd86 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd86" "Label100" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd88 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd88" "Label102" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd89 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd89" "Label263_29" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd92 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd92" "Label104" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd143 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd143" "Label122" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd94 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd94" "Label106" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd93 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd93" "Label263_32" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd96 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd96" "Label108" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd98 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd98" "Label110" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd100 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd100" "Label112" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd97 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd97" "Label263_35" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd150 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd150" "Label133" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd102 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd102" "Label114" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd152 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd152" "Label136" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd103 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd103" "Label263_38" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd104 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd104" "Label116" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd151 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd151" "Label134" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd153 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd153" "Label137" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd105 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd105" "Label263_41" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd106 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd106" "Label118" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd154 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd154" "Label140" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd155 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd155" "Label150" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd130 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd130" "Label263_44" vTcl:WidgetProc "Toplevel263" 1
    pack $site_4_0.cpd128 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd88 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd89 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd143 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd94 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd96 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd100 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd97 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd150 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd102 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd152 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd103 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd104 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd151 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd153 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd105 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd106 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd154 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd155 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd130 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.fra73 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra73" "Frame3" vTcl:WidgetProc "Toplevel263" 1
    set site_4_0 $site_3_0.fra73
    label $site_4_0.cpd129 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd129" "Label82" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd75 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd75" "Label263_45" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd107 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 8; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd107" "Button263_8" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd76 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd76" "Label263_47" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd77 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd77" "Label18" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd123 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd123" "Label263_49" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd109 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 9; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd109" "Button263_9" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd78 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd78" "Label263_51" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd79 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd79" "Label20" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd124 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd124" "Label263_53" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd111 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 10; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd111" "Button263_10" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd80 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd80" "Label263_55" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd81 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd81" "Label22" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd125 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd125" "Label263_57" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd113 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 11; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd113" "Button263_11" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd82 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd82" "Label263_59" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd83 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd83" "Label24" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd126 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd126" "Label263_61" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd115 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 12; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd115" "Button263_12" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd84 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd84" "Label263_63" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd85 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd85" "Label26" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd131 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd131" "Label263_65" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd117 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 13; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd117" "Button263_13" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd86 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd86" "Label263_67" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd87 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd87" "Label28" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd132 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd132" "Label263_69" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd119 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 14; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd119" "Button263_14" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd88 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd88" "Label263_71" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd89 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd89" "Label30" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd133 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd133" "Label263_73" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd120 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 15; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd120" "Button263_15" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd134 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftCorner.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd134" "Label263_75" vTcl:WidgetProc "Toplevel263" 1
    pack $site_4_0.cpd129 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd107 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd123 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd109 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd124 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd111 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd125 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd113 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd126 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd115 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd131 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd117 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd87 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd132 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd119 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd88 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd89 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd133 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd120 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd134 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd90 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd90" "Frame4" vTcl:WidgetProc "Toplevel263" 1
    set site_4_0 $site_3_0.cpd90
    label $site_4_0.cpd128 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd128" "Label81" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd75 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd75" "Label263_46" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd76 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd76" "Label32" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd77 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd77" "Label263_48" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd78 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd78" "Label34" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd79 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd79" "Label263_50" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd80 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd80" "Label36" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd81 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd81" "Label263_52" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd82 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd82" "Label38" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd83 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd83" "Label263_54" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd84 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd84" "Label40" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd85 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd85" "Label263_56" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd86 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd86" "Label42" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd87 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd87" "Label263_58" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd88 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd88" "Label44" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd89 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd89" "Label263_60" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd92 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd92" "Label46" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd93 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd93" "Label263_62" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd94 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd94" "Label48" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd95 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd95" "Label263_64" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd96 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd96" "Label50" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd97 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd97" "Label263_66" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd98 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd98" "Label52" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd99 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd99" "Label263_68" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd100 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd100" "Label54" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd101 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd101" "Label263_70" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd102 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd102" "Label56" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd103 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd103" "Label263_72" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd104 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd104" "Label58" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd105 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd105" "Label263_74" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd106 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd106" "Label60" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd130 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVertLine.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd130" "Label263_76" vTcl:WidgetProc "Toplevel263" 1
    pack $site_4_0.cpd128 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd87 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd88 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd89 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd94 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd95 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd96 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd97 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd99 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd100 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd101 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd102 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd103 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd104 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd105 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd106 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd130 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd122 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd122" "Frame5" vTcl:WidgetProc "Toplevel263" 1
    set site_4_0 $site_3_0.cpd122
    label $site_4_0.cpd127 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd127" "Label80" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd74 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 16; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd74" "Button263_16" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd75 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd75" "Label61" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd107 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 17; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd107" "Button263_17" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd76 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd76" "Label62" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd108 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 18; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd108" "Button263_18" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd77 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd77" "Label63" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd109 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 19; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd109" "Button263_19" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd78 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd78" "Label64" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd110 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 20; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd110" "Button263_20" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd79 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd79" "Label65" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd111 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 21; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd111" "Button263_21" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd80 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd80" "Label66" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd112 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 22; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd112" "Button263_22" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd81 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd81" "Label67" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd113 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 23; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd113" "Button263_23" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd82 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd82" "Label68" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd114 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 24; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd114" "Button263_24" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd83 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd83" "Label69" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd115 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 25; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd115" "Button263_25" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd84 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd84" "Label70" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd116 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 26; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd116" "Button263_26" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd85 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd85" "Label71" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd117 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 27; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd117" "Button263_27" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd86 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd86" "Label72" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd118 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 28; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd118" "Button263_28" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd87 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd87" "Label73" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd119 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 29; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd119" "Button263_29" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd88 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd88" "Label74" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd120 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 30; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd120" "Button263_30" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd89 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeVide.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd89" "Label75" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd121 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 31; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeNode.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd121" "Button263_31" vTcl:WidgetProc "Toplevel263" 1
    pack $site_4_0.cpd127 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd107 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd108 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd109 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd110 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd111 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd112 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd113 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd114 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd115 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd116 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd117 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd118 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd87 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd119 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd88 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd120 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd89 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd121 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd75 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd75" "Frame29" vTcl:WidgetProc "Toplevel263" 1
    set site_4_0 $site_3_0.cpd75
    label $site_4_0.cpd123
    vTcl:DefineAlias "$site_4_0.cpd123" "Label4" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd128 \
        -borderwidth 0 -highlightthickness 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd128" "Label263_77" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd75 \
        -borderwidth 0 -highlightthickness 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd75" "Label263_78" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd76 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd76" "Label263_79" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd77 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd77" "Label263_80" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd78 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd78" "Label263_81" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd79 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd79" "Label263_82" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd80 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd80" "Label263_83" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd81 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd81" "Label263_84" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd82 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd82" "Label263_85" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd83 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd83" "Label263_86" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd84 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd84" "Label263_87" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd85 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd85" "Label263_88" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd86 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd86" "Label263_89" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd87 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd87" "Label263_90" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd88 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd88" "Label263_91" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd89 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd89" "Label263_92" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd92 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd92" "Label263_93" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd93 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd93" "Label263_94" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd94 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd94" "Label263_95" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd95 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd95" "Label263_96" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd96 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd96" "Label263_97" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd97 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd97" "Label263_98" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd98 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd98" "Label263_99" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd99 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd99" "Label263_100" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd100 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd100" "Label263_101" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd101 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd101" "Label263_102" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd102 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd102" "Label263_103" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd103 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd103" "Label263_104" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd104 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd104" "Label263_105" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd105 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd105" "Label263_106" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd106 \
        -borderwidth 1 \
        -image [vTcl:image:get_image [file join . GUI Images TreeRightDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd106" "Label263_107" vTcl:WidgetProc "Toplevel263" 1
    label $site_4_0.cpd130 \
        -borderwidth 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeLeftDiag.gif]] \
        -text label 
    vTcl:DefineAlias "$site_4_0.cpd130" "Label263_108" vTcl:WidgetProc "Toplevel263" 1
    pack $site_4_0.cpd123 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd128 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd75 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd76 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 2 -side left 
    pack $site_4_0.cpd77 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd78 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd79 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd80 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd81 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd82 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd83 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd84 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd85 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd86 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd87 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd88 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd89 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd94 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd95 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd96 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd97 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd99 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd100 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd101 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd102 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd103 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd104 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd105 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd106 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd130 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd73 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd73" "Frame28" vTcl:WidgetProc "Toplevel263" 1
    set site_4_0 $site_3_0.cpd73
    label $site_4_0.cpd92
    vTcl:DefineAlias "$site_4_0.cpd92" "Label2" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd90 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 32; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd90" "Button263_32" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd74 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 33; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd74" "Button263_33" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd93 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 34; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd93" "Button263_34" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd107 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 35; TreeActiveNode $NodeNumber} \
        -highlightthickness 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd107" "Button263_35" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd94 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 36; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd94" "Button263_36" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd108 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 37; TreeActiveNode $NodeNumber} \
        -highlightthickness 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd108" "Button263_37" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd95 \
        -borderwidth 1 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 38; TreeActiveNode $NodeNumber} \
        -highlightthickness 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd95" "Button263_38" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd109 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 39; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd109" "Button263_39" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd96 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 40; TreeActiveNode $NodeNumber} \
        -highlightthickness 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd96" "Button263_40" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd110 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 41; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd110" "Button263_41" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd111 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 42; TreeActiveNode $NodeNumber} \
        -highlightthickness 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd111" "Button263_42" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd97 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 43; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd97" "Button263_43" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd112 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 44; TreeActiveNode $NodeNumber} \
        -highlightthickness 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd112" "Button263_44" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd98 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 45; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd98" "Button263_45" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd113 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 46; TreeActiveNode $NodeNumber} \
        -highlightthickness 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd113" "Button263_46" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd99 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 47; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd99" "Button263_47" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd114 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 48; TreeActiveNode $NodeNumber} \
        -highlightthickness 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd114" "Button263_48" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd100 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 49; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd100" "Button263_49" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd115 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 50; TreeActiveNode $NodeNumber} \
        -highlightthickness 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd115" "Button263_50" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd101 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 51; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd101" "Button263_51" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd116 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 52; TreeActiveNode $NodeNumber} \
        -highlightthickness 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd116" "Button263_52" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd102 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 53; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd102" "Button263_53" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd117 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 54; TreeActiveNode $NodeNumber} \
        -highlightthickness 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd117" "Button263_54" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd103 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 55; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd103" "Button263_55" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd118 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 56; TreeActiveNode $NodeNumber} \
        -highlightthickness 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd118" "Button263_56" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd104 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 57; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd104" "Button263_57" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd119 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 58; TreeActiveNode $NodeNumber} \
        -highlightthickness 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd119" "Button263_58" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd105 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 59; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd105" "Button263_59" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd120 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 60; TreeActiveNode $NodeNumber} \
        -highlightthickness 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd120" "Button263_60" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd106 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 61; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd106" "Button263_61" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd121 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 62; TreeActiveNode $NodeNumber} \
        -highlightthickness 0 \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd121" "Button263_62" vTcl:WidgetProc "Toplevel263" 1
    button $site_4_0.cpd122 \
        -borderwidth 0 \
        -command {global NodeNumber TreeNodeType

set NodeNumber 63; TreeActiveNode $NodeNumber} \
        -image [vTcl:image:get_image [file join . GUI Images TreeClass.gif]] \
        -padx 0 -pady 0 -relief flat -text button 
    vTcl:DefineAlias "$site_4_0.cpd122" "Button263_63" vTcl:WidgetProc "Toplevel263" 1
    pack $site_4_0.cpd92 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd90 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd93 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd107 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd94 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd108 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd95 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd109 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd96 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd110 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd111 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd97 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd112 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd98 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd113 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd99 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd114 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd100 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd115 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd101 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd116 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd102 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd117 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd103 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd118 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd104 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd119 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd105 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd120 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd106 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd121 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    pack $site_4_0.cpd122 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side left 
    frame $site_3_0.cpd177 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd177" "Frame12" vTcl:WidgetProc "Toplevel263" 1
    set site_4_0 $site_3_0.cpd177
    label $site_4_0.lab176 \
        -borderwidth 0 
    vTcl:DefineAlias "$site_4_0.lab176" "Label3" vTcl:WidgetProc "Toplevel263" 1
    pack $site_4_0.lab176 \
        -in $site_4_0 -anchor center -expand 0 -fill none -side top 
    pack $site_3_0.fra175 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd172 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd171 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd161 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd156 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd136 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd135 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.fra73 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd90 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd122 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd75 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd73 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    pack $site_3_0.cpd177 \
        -in $site_3_0 -anchor center -expand 0 -fill x -side top 
    frame $top.fra118 \
        -height 75 -width 125 
    vTcl:DefineAlias "$top.fra118" "Frame15" vTcl:WidgetProc "Toplevel263" 1
    set site_3_0 $top.fra118
    frame $site_3_0.cpd119 \
        -borderwidth 2 -relief sunken -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.cpd119" "Frame16" vTcl:WidgetProc "Toplevel263" 1
    set site_4_0 $site_3_0.cpd119
    radiobutton $site_4_0.rad112 \
        \
        -command {global NodeNumber NodeType

if {$NodeNumber < 32} {
    NodeON $NodeNumber
    TreeCreateNode $NodeNumber
    TreeActiveNode 0; TreeActiveNode $NodeNumber
    } else {
    set NodeType "class"
    }} \
        -text Node -value node -variable NodeType 
    vTcl:DefineAlias "$site_4_0.rad112" "Radiobutton263_1" vTcl:WidgetProc "Toplevel263" 1
    radiobutton $site_4_0.rad113 \
        \
        -command {global NodeNumber NodeType

if {$NodeNumber != 1} {
    ClassON $NodeNumber
    TreeCreateClass $NodeNumber
    TreeActiveNode 0; TreeActiveNode $NodeNumber
    } else {
    set NodeType "node"
    }} \
        -text Class -value class -variable NodeType 
    vTcl:DefineAlias "$site_4_0.rad113" "Radiobutton263_2" vTcl:WidgetProc "Toplevel263" 1
    frame $site_4_0.fra114 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra114" "Frame17" vTcl:WidgetProc "Toplevel263" 1
    set site_5_0 $site_4_0.fra114
    label $site_5_0.lab115 \
        -text {Class Number} 
    vTcl:DefineAlias "$site_5_0.lab115" "Label263_120" vTcl:WidgetProc "Toplevel263" 1
    entry $site_5_0.ent116 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NodeClass -width 5 
    vTcl:DefineAlias "$site_5_0.ent116" "Entry263_120" vTcl:WidgetProc "Toplevel263" 1
    pack $site_5_0.lab115 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_5_0.ent116 \
        -in $site_5_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.rad112 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.rad113 \
        -in $site_4_0 -anchor center -expand 1 -fill none -padx 10 -side left 
    pack $site_4_0.fra114 \
        -in $site_4_0 -anchor center -expand 0 -fill none -padx 5 -side top 
    frame $site_3_0.fra73 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_3_0.fra73" "Frame26" vTcl:WidgetProc "Toplevel263" 1
    set site_4_0 $site_3_0.fra73
    TitleFrame $site_4_0.cpd74 \
        -ipad 0 -text {Node Definition} 
    vTcl:DefineAlias "$site_4_0.cpd74" "TitleFrame263_1" vTcl:WidgetProc "Toplevel263" 1
    bind $site_4_0.cpd74 <Destroy> {
        Widget::destroy %W; rename %W {}
    }
    set site_6_0 [$site_4_0.cpd74 getframe]
    frame $site_6_0.fra75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra75" "Frame14" vTcl:WidgetProc "Toplevel263" 1
    set site_7_0 $site_6_0.fra75
    frame $site_7_0.cpd76 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd76" "Frame13" vTcl:WidgetProc "Toplevel263" 1
    set site_8_0 $site_7_0.cpd76
    label $site_8_0.lab122 \
        -text {Parameter 1} 
    vTcl:DefineAlias "$site_8_0.lab122" "Label263_121" vTcl:WidgetProc "Toplevel263" 1
    ComboBox $site_8_0.cpd74 \
        -entrybg white -takefocus 1 -textvariable TreePara1 
    vTcl:DefineAlias "$site_8_0.cpd74" "ComboBox263_121" vTcl:WidgetProc "Toplevel263" 1
    bindtags $site_8_0.cpd74 "$site_8_0.cpd74 BwComboBox $top all"
    pack $site_8_0.lab122 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_8_0.cpd74 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd77 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd77" "Frame25" vTcl:WidgetProc "Toplevel263" 1
    set site_8_0 $site_7_0.cpd77
    label $site_8_0.lab122 \
        -text {Parameter 2} 
    vTcl:DefineAlias "$site_8_0.lab122" "Label263_122" vTcl:WidgetProc "Toplevel263" 1
    ComboBox $site_8_0.cpd75 \
        -entrybg white -takefocus 1 -textvariable TreePara2 
    vTcl:DefineAlias "$site_8_0.cpd75" "ComboBox263_122" vTcl:WidgetProc "Toplevel263" 1
    bindtags $site_8_0.cpd75 "$site_8_0.cpd75 BwComboBox $top all"
    pack $site_8_0.lab122 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_8_0.cpd75 \
        -in $site_8_0 -anchor center -expand 0 -fill none -side left 
    pack $site_7_0.cpd76 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd77 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    frame $site_6_0.fra127 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_6_0.fra127" "Frame18" vTcl:WidgetProc "Toplevel263" 1
    set site_7_0 $site_6_0.fra127
    frame $site_7_0.fra128 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra128" "Frame19" vTcl:WidgetProc "Toplevel263" 1
    set site_8_0 $site_7_0.fra128
    label $site_8_0.lab129 \
        -text {Weighting Coeff 1} 
    vTcl:DefineAlias "$site_8_0.lab129" "Label263_123" vTcl:WidgetProc "Toplevel263" 1
    entry $site_8_0.ent130 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NodeCoeff1 -width 5 
    vTcl:DefineAlias "$site_8_0.ent130" "Entry263_123" vTcl:WidgetProc "Toplevel263" 1
    pack $site_8_0.lab129 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_8_0.ent130 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 5 -side top 
    frame $site_7_0.cpd131 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd131" "Frame20" vTcl:WidgetProc "Toplevel263" 1
    set site_8_0 $site_7_0.cpd131
    label $site_8_0.lab129 \
        -text {Weighting Coeff 2} 
    vTcl:DefineAlias "$site_8_0.lab129" "Label263_124" vTcl:WidgetProc "Toplevel263" 1
    entry $site_8_0.ent130 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NodeCoeff2 -width 5 
    vTcl:DefineAlias "$site_8_0.ent130" "Entry263_124" vTcl:WidgetProc "Toplevel263" 1
    pack $site_8_0.lab129 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_8_0.ent130 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 5 -side top 
    frame $site_7_0.fra133 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.fra133" "Frame22" vTcl:WidgetProc "Toplevel263" 1
    set site_8_0 $site_7_0.fra133
    label $site_8_0.lab135 \
        -text Operator 
    vTcl:DefineAlias "$site_8_0.lab135" "Label263_125" vTcl:WidgetProc "Toplevel263" 1
    frame $site_8_0.fra134 \
        -height 75 -width 125 
    vTcl:DefineAlias "$site_8_0.fra134" "Frame23" vTcl:WidgetProc "Toplevel263" 1
    set site_9_0 $site_8_0.fra134
    radiobutton $site_9_0.rad136 \
        -borderwidth 0 -text { > } -value sup -variable NodeOperator 
    vTcl:DefineAlias "$site_9_0.rad136" "Radiobutton263_125" vTcl:WidgetProc "Toplevel263" 1
    radiobutton $site_9_0.cpd137 \
        -borderwidth 0 -text { < } -value inf -variable NodeOperator 
    vTcl:DefineAlias "$site_9_0.cpd137" "Radiobutton263_126" vTcl:WidgetProc "Toplevel263" 1
    pack $site_9_0.rad136 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side top 
    pack $site_9_0.cpd137 \
        -in $site_9_0 -anchor center -expand 0 -fill none -side top 
    pack $site_8_0.lab135 \
        -in $site_8_0 -anchor center -expand 1 -fill none -padx 5 -side left 
    pack $site_8_0.fra134 \
        -in $site_8_0 -anchor center -expand 1 -fill none -side left 
    frame $site_7_0.cpd132 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_7_0.cpd132" "Frame21" vTcl:WidgetProc "Toplevel263" 1
    set site_8_0 $site_7_0.cpd132
    label $site_8_0.lab129 \
        -text {Threshold Coeff } 
    vTcl:DefineAlias "$site_8_0.lab129" "Label263_126" vTcl:WidgetProc "Toplevel263" 1
    entry $site_8_0.ent130 \
        -background white -foreground #ff0000 -justify center \
        -textvariable NodeCoeff3 -width 5 
    vTcl:DefineAlias "$site_8_0.ent130" "Entry263_126" vTcl:WidgetProc "Toplevel263" 1
    pack $site_8_0.lab129 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 5 -side left 
    pack $site_8_0.ent130 \
        -in $site_8_0 -anchor center -expand 0 -fill none -padx 5 -side top 
    pack $site_7_0.fra128 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd131 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.fra133 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_7_0.cpd132 \
        -in $site_7_0 -anchor center -expand 1 -fill none -side left 
    pack $site_6_0.fra75 \
        -in $site_6_0 -anchor center -expand 1 -fill both -padx 10 -side top 
    pack $site_6_0.fra127 \
        -in $site_6_0 -anchor center -expand 0 -fill both -side top 
    frame $site_4_0.fra75 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$site_4_0.fra75" "Frame27" vTcl:WidgetProc "Toplevel263" 1
    set site_5_0 $site_4_0.fra75
    button $site_5_0.cpd76 \
        -background #ffff00 \
        -command {global NodeNumber TreeNodeType
global TreeNodePara1 TreeNodePara2
global TreeNodeCoeff1 TreeNodeCoeff2
global TreeNodeCoeff3 TreeNodeOperator
global TreeNodeClass
global NodeCoeff1 NodeCoeff2 NodeCoeff3
global NodeClass NodeOperator
global TestVarError TestVarName TestVarType TestVarValue TestVarMin TestVarMax

if {$TreeNodeType($NodeNumber) == "node" } {
    set TestVarName(0) "Weighting Coeff1"; set TestVarType(0) "float"; set TestVarValue(0) $NodeCoeff1; set TestVarMin(0) "-9999.99"; set TestVarMax(0) "9999.99"
    set TestVarName(1) "Weighting Coeff2"; set TestVarType(1) "float"; set TestVarValue(1) $NodeCoeff2; set TestVarMin(1) "-9999.99"; set TestVarMax(1) "9999.99"
    set TestVarName(2) "Weighting Coeff3"; set TestVarType(2) "float"; set TestVarValue(2) $NodeCoeff3; set TestVarMin(2) "-9999.99"; set TestVarMax(2) "9999.99"
    TestVar 3
    if {$TestVarError == "ok"} {
        set TreePara1Id [.top263.fra118.fra73.cpd74.f.fra75.cpd76.cpd74 getvalue]
        if {$TreePara1Id != "-1"} {
            set TreeNodePara1($NodeNumber) [expr $TreePara1Id + 1]
            } else {
            if {$NodeCoeff1 == 0} {
                set TreeNodePara1($NodeNumber) $TreeNodePara2($NodeNumber)
                } else {
                set TreeNodePara1($NodeNumber) "XX"
                }
            }
        set TreePara2Id [.top263.fra118.fra73.cpd74.f.fra75.cpd77.cpd75 getvalue]
        if {$TreePara2Id != "-1"} {
            set TreeNodePara2($NodeNumber) [expr $TreePara2Id + 1]
            } else {
            if {$NodeCoeff2 == 0} {
                set TreeNodePara2($NodeNumber) $TreeNodePara1($NodeNumber)
                } else {
                set TreeNodePara2($NodeNumber) "XX"
                }
            }
        set TreeNodeCoeff1($NodeNumber) $NodeCoeff1
        set TreeNodeCoeff2($NodeNumber) $NodeCoeff2
        set TreeNodeCoeff3($NodeNumber) $NodeCoeff3
        set TreeNodeOperator($NodeNumber) $NodeOperator
        set TreeNodeClass($NodeNumber) "XX"
        }
    }
if {$TreeNodeType($NodeNumber) == "class" } {
    set TestVarName(0) "Class Number"; set TestVarType(0) "int"; set TestVarValue(0) $NodeClass; set TestVarMin(0) "0"; set TestVarMax(0) "64"
    TestVar 1
    if {$TestVarError == "ok"} {
        set TreeNodePara1($NodeNumber) "XX"
        set TreeNodePara2($NodeNumber) "XX"
        set TreeNodeCoeff1($NodeNumber) "XX"
        set TreeNodeCoeff2($NodeNumber) "XX"
        set TreeNodeCoeff3($NodeNumber) "XX"
        set TreeNodeOperator($NodeNumber) "XX"
        set TreeNodeClass($NodeNumber) $NodeClass
        }
    }
    
TreeActiveNode $NodeNumber} \
        -padx 4 -pady 2 -text Enter 
    vTcl:DefineAlias "$site_5_0.cpd76" "Button3" vTcl:WidgetProc "Toplevel263" 1
    pack $site_5_0.cpd76 \
        -in $site_5_0 -anchor center -expand 1 -fill none -side top 
    pack $site_4_0.cpd74 \
        -in $site_4_0 -anchor center -expand 1 -fill none -side left 
    pack $site_4_0.fra75 \
        -in $site_4_0 -anchor center -expand 0 -fill y -side right 
    pack $site_3_0.cpd119 \
        -in $site_3_0 -anchor center -expand 0 -fill none -pady 5 -side top 
    pack $site_3_0.fra73 \
        -in $site_3_0 -anchor center -expand 1 -fill both -side top 
    frame $top.fra142 \
        -borderwidth 2 -height 75 -width 125 
    vTcl:DefineAlias "$top.fra142" "Frame24" vTcl:WidgetProc "Toplevel263" 1
    set site_3_0 $top.fra142
    button $site_3_0.cpd78 \
        -background #ffff00 -command {TreeNodeRAZ
TreeInitStructure} -padx 4 \
        -pady 2 -text Reset 
    vTcl:DefineAlias "$site_3_0.cpd78" "Button4" vTcl:WidgetProc "Toplevel263" 1
    button $site_3_0.cpd145 \
        -background #ff8000 \
        -command {HelpPdfEdit "Help/HierarchicalTreeArchitecture.pdf"} \
        -image [vTcl:image:get_image [file join . GUI Images help.gif]] \
        -padx 4 -pady 2 -text button 
    vTcl:DefineAlias "$site_3_0.cpd145" "Button5" vTcl:WidgetProc "Toplevel263" 1
    button $site_3_0.cpd146 \
        -background #ffff00 \
        -command {global OpenDirFile
global HierarchicalDirOutput HierarchicalOutputDir HierarchicalOutputSubDir
global TreeInputStructureFile
global WarningMessage WarningMessage2 VarWarning
global TreeNodeType TreeNodeClass
global TreeNodePara1 TreeNodePara2
global TreeNodeCoeff1 TreeNodeCoeff2
global TreeNodeCoeff3 TreeNodeOperator

if {$OpenDirFile == 0} {

set config "true"
#Check All the Parameters
for {set i 1} {$i < 64} {incr i} {
    if {$TreeNodeType($i) == "node" } {
        if {$TreeNodeCoeff1($i) == "XX"} {set config "false"}
        if {$TreeNodeCoeff2($i) == "XX"} {set config "false"}
        if {$TreeNodeCoeff3($i) == "XX"} {set config "false"}
        if {$TreeNodePara1($i) == "XX"} {set config "false"}
        if {$TreeNodePara2($i) == "XX"} {set config "false"}
        }
    if {$TreeNodeType($i) == "class" } {
        if {$TreeNodeClass($i) == "XX"} {set config "false"}
        }
    }

if {$config == "false" } {
    set WarningMessage "WRONG NODE PARAMETERS : IMPOSSIBLE TO SAVE"
    set WarningMessage2 "EXIT WITHOUT SAVING ?"
    set VarWarning ""
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {Window hide $widget(Toplevel263); TextEditorRunTrace "Close Window Hierarchical Classification - Tree Structure Definition" "b"}
    } else {

#Check If Different Class Numbers
set ClassNode(0) 0        
for {set i 0} {$i <= 64} {incr i} { set ClassNode($i) "" }
set config "true"
for {set i 1} {$i < 64} {incr i} {
    if {$TreeNodeType($i) == "class" } {
        set ClassNum $TreeNodeClass($i)
        if {$ClassNode($ClassNum) == ""} {
            set ClassNode($ClassNum) "X"
            } else {
            set config "false"
            }
        }
    }
    
if {$config == "false" } {
    set WarningMessage "DUPLICATE CLASS NUMBERS : IMPOSSIBLE TO SAVE"
    set WarningMessage2 "EXIT WITHOUT SAVING ?"
    set VarWarning ""
    Window show $widget(Toplevel32); TextEditorRunTrace "Open Window Warning" "b"
    tkwait variable VarWarning
    if {"$VarWarning"=="ok"} {Window hide $widget(Toplevel263); TextEditorRunTrace "Close Window Hierarchical Classification - Tree Structure Definition" "b"}
    } else {
    #SAVE and EXIT
    set HierarchicalDirOutput $HierarchicalOutputDir
    if {$HierarchicalOutputSubDir != ""} {append HierarchicalDirOutput "/$HierarchicalOutputSubDir"}

    #####################################################################
    #Create Directory
    set HierarchicalDirOutput [PSPCreateDirectoryMask $HierarchicalDirOutput $HierarchicalOutputDir $HierarchicalDirInput]
    #####################################################################       

    if {"$VarWarning"=="ok"} {
        set TreeInputStructureFile "$HierarchicalDirOutput/tree_structure.txt"
        set f [open $TreeInputStructureFile w]
        puts $f "TREE STRUCTURE"
        for {set i 1} {$i < 64} {incr i} {
            puts $f $i
            puts $f $TreeNodeType($i)
            if {$TreeNodeType($i) == "node" } {
                puts $f $TreeNodePara1($i)
                puts $f $TreeNodePara2($i)
                puts $f $TreeNodeCoeff1($i)
                puts $f $TreeNodeCoeff2($i)
                puts $f $TreeNodeCoeff3($i)
                puts $f $TreeNodeOperator($i)
                }            
            if {$TreeNodeType($i) == "class" } {
                puts $f $TreeNodeClass($i)
                }            
            puts $f "----------"
            }
        close $f
        }
    Window hide $widget(Toplevel263); TextEditorRunTrace "Close Window Hierarchical Classification - Tree Structure Definition" "b"
    }
}
}} \
        -padx 4 -pady 2 -text {Save & Exit} 
    vTcl:DefineAlias "$site_3_0.cpd146" "Button7" vTcl:WidgetProc "Toplevel263" 1
    pack $site_3_0.cpd78 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd145 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    pack $site_3_0.cpd146 \
        -in $site_3_0 -anchor center -expand 1 -fill none -side left 
    ###################
    # SETTING GEOMETRY
    ###################
    pack $top.fra74 \
        -in $top -anchor center -expand 0 -fill none -side top 
    pack $top.fra118 \
        -in $top -anchor center -expand 0 -fill x -side top 
    pack $top.fra142 \
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

Window show .
Window show .top263

main $argc $argv
