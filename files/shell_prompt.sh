#!/bin/bash
# File managed by Puppet

if ! command tput sgr0 >/dev/null 2>&1 ; then
  return
fi

__PROMPT_TERM=""

__sessionm_prompt_updateterm() {
    ## C_BLK="\[$(tput setaf 0)\]"
    C_RED="\[$(tput setaf 1)\]"
    C_GRN="\[$(tput setaf 2)\]"
    C_YLW="\[$(tput setaf 3)\]"
    # C_BLU="\[$(tput setaf 4)\]"
    # C_MGN="\[$(tput setaf 5)\]"
    C_CYA="\[$(tput setaf 6)\]"
    C_LGY="\[$(tput setaf 7)\]"
    # C_DGY="\[$(tput setaf 8)\]"
    C_WHT="\[$(tput setaf 15)\]"
    C_BRED="\[$(tput setab 1)\]"
    C_BGRN="\[$(tput setab 2)\]"
    C_BYLW="\[$(tput setab 3)\]"
    C_BCYA="\[$(tput setab 6)\]"
    # C_REV="\[$(tput rev)\]"
    C_R="\[$(tput sgr0)\]"
    C_BOLD="\[$(tput bold)\]"
    C_DIM="\[$(tput dim)\]"
    __PROMPT_TERM="${TERM}"
    __PROMPT_HOSTNAME=""
    __PROMPT_ENV=""
    __PROMPT_INS="\h"
    __PROMPT_LOADAVG=""
    __PROMPT_PATH=""
    __PROMPT_MEMAVIAL=""
    __PROMPT_CORES=$(nproc)
    __PROMPT_VIRTUAL_ENV=""
    __PROMPT_VIRTUAL_ENV_LAST=""
    __PROMPT_RVM=""
    __PROMPT_RVM_LAST=""
}

__sessionm_prompt_loadavg() {
    if [ -n "${_PROMPT_LOAD+x}" ] && [ "${_PROMPT_LOAD}" -eq 0 ] ; then
        return
    fi

    read -r -a LOAD -d " " < /proc/loadavg
    local M_LOAD=$(( ( __PROMPT_CORES * 10000 ) / 2 ))
    local L_LOAD=$(( M_LOAD / 2 ))
    local H_LOAD=$(( L_LOAD + M_LOAD ))
    local F_LOAD=$(( M_LOAD + M_LOAD ))
    local C_HI=""

    __PROMPT_LOADAVG=""

    local L_ILAVG=0
    local L_FLAVG=0
    for ((i=0;i<3;i++)) ; do
        _C="${C_GRN}"
        ILAVG="${LOAD[$i]//./}"
        ILAVG="${ILAVG#0*}00"
        if [ "${L_ILAVG}" -ge "${ILAVG}" ] ; then
            continue
        fi
        L_ILAVG="$ILAVG"

        printf -v FLAVG "%.1f" "${LOAD[$i]}"
        if [ "${L_FLAVG}" == "${FLAVG}" ] ; then
            continue
        fi
        L_FLAVG="${FLAVG}"

        __PROMPT_LOADAVG+="${C_R}"
 
        if [ "$ILAVG" -lt $L_LOAD ] ; then
            __PROMPT_LOADAVG+="${C_LGY}"
        elif [ "$ILAVG" -lt $M_LOAD ] ; then
            __PROMPT_LOADAVG+="${C_GRN}"
            C_HI="${C_HI:-$C_GRN}"
        elif [ "$ILAVG" -lt $H_LOAD ] ; then
            __PROMPT_LOADAVG+="${C_YLW}"
            C_HI="${C_HI:-$C_YLW}"
        elif [ "$ILAVG" -lt "$F_LOAD" ] ; then
            __PROMPT_LOADAVG+="${C_RED}"
            C_HI="${C_RED}"
        else
            __PROMPT_LOADAVG+="${C_BOLD}${C_RED}"
            C_HI="${C_BOLD}${C_RED}"
        fi
        __PROMPT_LOADAVG+="${FLAVG}${C_R}${C_DIM},"
    done
    __sessionm_prompt_memavail
    __PROMPT_LOADAVG="${C_R}${C_HI}[${__PROMPT_LOADAVG%?}${C_R}${C_HI},${__PROMPT_MEMAVAIL}%]"
}

__sessionm_prompt_memavail() {
    local _C=""
    # shellcheck disable=SC2207
    local mem=($(< /proc/meminfo))
    local avail=$((100 * mem[7] / mem[1]))

    __PROMPT_MEMAVAIL="${avail}"
}

__sessionm_prompt_hostname() {
    local _C=""
    local _CB=""
    local _PUPPET_ENV="$(/opt/puppetlabs/bin/puppet config print environment)"
    local _ROLE=""

    _ROLE=$(/opt/puppetlabs/puppet/bin/ruby -r json -e "puts JSON.parse(File.read('/etc/facter/facts.d/test.json'))['role']")

    # Environment
    case $_PUPPET_ENV in
    production)
        _CB="${C_BRED}" && _C="${C_YLW}" ;;
    staging)
        _CB="${C_BYLW}" && _C="${C_RED}" ;;
    *)
        _CB="${C_BGRN}" && _C="${C_WHT}" ;;
    esac

    __PROMPT_ENV="${_CB} ${_C}${C_BOLD}${_PUPPET_ENV}${C_R}${_CB}${_C} ${_ROLE} "
    __PROMPT_HOSTNAME=${HOSTNAME//.*}
}

__sessionm_prompt_path() {
  local PARTS=()
  local TPWD="$PWD"

  __PROMPT_PATH="${C_R}"

  local DIRS
  OIFS="${IFS}"
  set -f
  IFS=$'\n'
  DIRS=("$(dirs -p)")
  set +f
  IFS="${OIFS}"
  if [[ ${#DIRS[@]} -gt 1 ]] ; then
    __PROMPT_PATH+="${C_DIM}${#DIRS[@]}${C_R}"
  fi

  if [[ "$TPWD" =~ ^${HOME}.* ]] ; then
    TPWD="~${TPWD#"$HOME"}"
  fi
  IFS=/ read -r -a PARTS <<<"$TPWD"

  MINPART=$(( ${#PARTS[@]} - 3 ))
  if [ $MINPART -le 1 ] ; then
    __PROMPT_PATH+="${TPWD}"
    return 0
  else
    __PROMPT_PATH+="…"
  fi

  for ((i="$MINPART";i<${#PARTS[@]};i++)) ; do
    __PROMPT_PATH+="${C_DIM}/${C_R}${PARTS[$i]}"
  done
}

__sessionm_prompt() {
    local LEXIT="$?"
    local STATS=""

    if [ "$__PROMPT_TERM" != "$TERM" ] ; then
        __sessionm_prompt_updateterm
    fi

    PS1=""
    SEP="${C_R} "

    if [ "$__PROMPT_HOSTNAME" != "$HOSTNAME" ] ; then
      __sessionm_prompt_hostname
    fi

    PS1+="${C_R}${__PROMPT_ENV}"

    # User
    if [[ "${USER}" == "root" ]] ; then
      U_COLOR="${C_RED}${C_BOLD}"
    elif [[ ${EUID} -lt 1000 ]] ; then
        U_COLOR+="${C_YLW}"
    elif [[ -n "${SUDO_USER}" ]] ; then
        U_COLOR+="${C_CYA}"
    fi
    PS1+="${SEP}${U_COLOR}\u${C_LGY}${C_BOLD}@${C_R}${__PROMPT_INS}"

    # Stats
    [ "${SHLVL}" -gt 1 ] && STATS+="${C_R}${SHLVL}${C_DIM},"
    [ "$(jobs -p)" != "" ] && STATS+="${C_R}\j${C_DIM},"
    if [ -n "${STATS}" ] ; then
        PS1+="${SEP}${C_DIM}[${C_R}${STATS%?}${C_DIM}]"
    fi

    # Load
    __sessionm_prompt_loadavg
    PS1+="${SEP}${__PROMPT_LOADAVG}"

    # Virtualenv
    if [[ "${__PROMPT_VIRTUAL_ENV_LAST}" != "${VIRTUAL_ENV:-}" ]] ; then
        if [ -z "${VIRTUAL_ENV+x}" ] ; then
            __PROMPT_VIRTUAL_ENV=""
            __PROMPT_VIRTUAL_ENV_LAST=""
        else
            __PROMPT_VIRTUAL_ENV="${SEP}(${VIRTUAL_ENV##*/})"
            __PROMPT_VIRTUAL_ENV_LAST="${VIRTUAL_ENV}"
        fi
    fi
    PS1+="${__PROMPT_VIRTUAL_ENV}"

    # RVM
    if [[ "${__PROMPT_RVM_LAST}" != "${RUBY_VERSION:-}" ]] ; then
        if [ -z "${RUBY_VERSION+x}" ] ; then
            __PROMPT_RVM=""
            __PROMPT_RVM=""
        else
            __PROMPT_RVM="${SEP}(${RUBY_VERSION})"
            __PROMPT_RVM_LAST="${RUBY_VERSION}"
        fi
    fi
    PS1+="${__PROMPT_RVM}"

    # Path
    __sessionm_prompt_path
    PS1+="${SEP}${__PROMPT_PATH}${C_R}${C_LGY}${C_BOLD}"

    # Status
    [ -w "$PWD" ] || PS1+="${C_RED}"
    [ ${EUID} -lt 1000 ] && PS1+="${C_YLW}"
    PS1+="\\\$${C_R} ";

    # Last exit code > 0
    if [ $LEXIT -gt 0 ] ; then
        PS1+="${C_BRED} ${LEXIT} ${C_R} "
    fi
}

PROMPT_COMMAND=__sessionm_prompt
