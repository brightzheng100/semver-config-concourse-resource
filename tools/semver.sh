#!/usr/bin/env sh

function semverParseInto() {
    local RE='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
    #MAJOR
    eval $2=`echo $1 | sed -e "s#$RE#\1#"`
    #MINOR
    eval $3=`echo $1 | sed -e "s#$RE#\2#"`
    #MINOR
    eval $4=`echo $1 | sed -e "s#$RE#\3#"`
    #SPECIAL
    eval $5=`echo $1 | sed -e "s#$RE#\4#"`
}

# detect whether there is a major version change
# usage: 
#   semverDetectMajorChange a.b.c x.y.z
# return:
#   true    - if a.b.c -> x.y.z has major version change
#   false   - if not
function semverDetectMajorChange() {
    local MAJOR_A=0
    local MINOR_A=0
    local PATCH_A=0
    local SPECIAL_A=0

    local MAJOR_B=0
    local MINOR_B=0
    local PATCH_B=0
    local SPECIAL_B=0

    semverParseInto $1 MAJOR_A MINOR_A PATCH_A SPECIAL_A
    semverParseInto $2 MAJOR_B MINOR_B PATCH_B SPECIAL_B

    if [ $MAJOR_B -gt $MAJOR_A ]; then
        echo true && return 0
    fi

    echo false && return 0
}

# detect whether there is a minor version change
# usage: 
#   semverDetectMinorChange a.b.c x.y.z
# return:
#   true    - if a.b.c -> x.y.z has minor version change
#   false   - if not
function semverDetectMinorChange() {
    local MAJOR_A=0
    local MINOR_A=0
    local PATCH_A=0
    local SPECIAL_A=0

    local MAJOR_B=0
    local MINOR_B=0
    local PATCH_B=0
    local SPECIAL_B=0

    semverParseInto $1 MAJOR_A MINOR_A PATCH_A SPECIAL_A
    semverParseInto $2 MAJOR_B MINOR_B PATCH_B SPECIAL_B

    if [ $MAJOR_B -eq $MAJOR_A ] && [ $MINOR_B -gt $MINOR_A ]; then
        echo true && return 0
    fi

    echo false && return 0
}

# detect whether there is a patch version change
# usage: 
#   semverDetectMinorChange a.b.c x.y.z
# return:
#   true    - if a.b.c -> x.y.z has patch version change
#   false   - if not
function semverDetectPatchChange() {
    local MAJOR_A=0
    local MINOR_A=0
    local PATCH_A=0
    local SPECIAL_A=0

    local MAJOR_B=0
    local MINOR_B=0
    local PATCH_B=0
    local SPECIAL_B=0

    semverParseInto $1 MAJOR_A MINOR_A PATCH_A SPECIAL_A
    semverParseInto $2 MAJOR_B MINOR_B PATCH_B SPECIAL_B

    if [ $MAJOR_B -eq $MAJOR_A ] && [ $MINOR_B -eq $MINOR_A ] && [ $PATCH_B -gt $PATCH_A ]; then
        echo true && return 0
    fi

    echo false && return 0
}

if [ "___semver.sh"="___`basename $0`" ] && [ $# -eq 2 ]; then

    MAJOR=0
    MINOR=0
    PATCH=0
    SPECIAL=""

    semverParseInto $1 MAJOR MINOR PATCH SPECIAL
    echo "$1 -> M: $MAJOR m:$MINOR p:$PATCH s:$SPECIAL"

    semverParseInto $2 MAJOR MINOR PATCH SPECIAL
    echo "$2 -> M: $MAJOR m:$MINOR p:$PATCH s:$SPECIAL"

    echo "--> semverDetectMajorChange $1 -> $2: `semverDetectMajorChange $1 $2`"
    echo "--> semverDetectMinorChange $1 -> $2: `semverDetectMinorChange $1 $2`"
    echo "--> semverDetectPatchChange $1 -> $2: `semverDetectPatchChange $1 $2`"

fi