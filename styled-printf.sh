#!/bin/bash
# @author Mauro Alvarez
# NOTE: In order to make this command dependency-free I copied a couple of function from
# https://github.com/labbots/bash-utility/ (thanks Labbots team!)
# I know... I could include that repo as a Git submodule, but most devs (including myself)
# forget to use the --recurse-submodules flag in the git clone. Plus, bash-utility is too big
# for this simple command, including the whole library would be the same than killing
# a fly with a bazooka

# set -e

# @description Make a string lowercase. (source: bash-utility)
#
# @example
#   echo "$(string::to_lower "HellO")"
#   #Output
#   hello
#
# @arg $1 string The input string.
#
# @exitcode 0  If successful.
# @exitcode 2 Function missing arguments.
#
# @stdout Returns the lowercased string.
string::to_lower() {
    [[ $# = 0 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    if [[ ${BASH_VERSINFO:-0} -ge 4 ]]; then
        printf '%s\n' "${1,,}"
    else
        printf "%s\n" "${@}" | tr '[:upper:]' '[:lower:]'
    fi
}

# @description Make a string all uppercase. (source: bash-utility)
#
# @example
#   echo "$(string::to_upper "HellO")"
#   #Output
#   HELLO
#
# @arg $1 string The input string.
#
# @exitcode 0  If successful.
# @exitcode 2 Function missing arguments.
#
# @stdout Returns the uppercased string.
string::to_upper() {
    [[ $# = 0 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2
    if [[ ${BASH_VERSINFO:-0} -ge 4 ]]; then
        printf '%s\n' "${1^^}"
    else
        printf "%s\n" "${@}" | tr '[:lower:]' '[:upper:]'
    fi
}

# @description Check if given variable contains only alpha-numeric characters. (source: bash-utility)
#
# @example
#   test='abc123'
#   validation::alpha_num "${test}"
#   echo $?
#   #Output
#   0
#
# @arg $1 string Value of variable to validate.
#
# @exitcode 0  If input is an alpha-numeric.
# @exitcode 1 If input is not an alpha-numeric.
# @exitcode 2 Function missing arguments.
validation::alpha_num() {
    [[ $# = 0 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && return 2

    declare re='^[[:alnum:]]+$'
    if [[ "${1}" =~ $re ]]; then
        return 0
    fi
    return 1
}

# @description Check if given variable is an integer. (source: bash-utility)
#
# @example
#   variable::is_int "+1234"
#   #Output
#   0
#
# @arg $1 mixed Value of variable to check.
#
# @exitcode 0  If input is an integer.
# @exitcode 1 If input is not an integer.
variable::is_int() {
    declare re='^[+]?[0-9]+$'
    if [[ ${1} =~ $re ]]; then
        return 0
    fi
    return 1
}

# Text color
COLOR_DEFAULT='39'
COLOR_WHITE='97'
COLOR_BACK='30'
COLOR_RED='31'
COLOR_GREEN='32'
COLOR_YELLOW='33'
COLOR_BLUE='34'
COLOR_MAGENTA='35'
COLOR_CYAN='36'
COLOR_GRAY='90'
COLOR_LIGHT_RED='91'
COLOR_LIGHT_GREEN='92'
COLOR_LIGHT_YELLOW='93'
COLOR_LIGHT_BLUE='94'
COLOR_LIGHT_MAGENTA='95'
COLOR_LIGHT_CYAN='96'
COLOR_LIGHT_GRAY='37'

# # Text background color
BG_COLOR_DEFAULT='49'
BG_COLOR_WHITE='107'
BG_COLOR_BACK='40'
BG_COLOR_RED='41'
BG_COLOR_GREEN='42'
BG_COLOR_YELLOW='43'
BG_COLOR_BLUE='44'
BG_COLOR_MAGENTA='45'
BG_COLOR_CYAN='46'
BG_COLOR_GRAY='100'
BG_COLOR_LIGHT_RED='101'
BG_COLOR_LIGHT_GREEN='102'
BG_COLOR_LIGHT_YELLOW='103'
BG_COLOR_LIGHT_BLUE='104'
BG_COLOR_LIGHT_MAGENTA='105'
BG_COLOR_LIGHT_CYAN='106'
BG_COLOR_LIGHT_GRAY='47'

# Text Style
STYLE_NORMAL='0'
STYLE_BOLD='1'
STYLE_DIM='2'
STYLE_ITALICS='3'
STYLE_UNDERLINE='4'
STYLE_BLINK='5'
STYLE_REVERSE='7'
STYLE_HIDDEN='8'
STYLE_PASSWORD='8'


RESET_STYLE='\e[0m'

# text style values
styleValue=${STYLE_NORMAL}
textColorValue=${COLOR_DEFAULT}
backgroundColorValue=${BG_COLOR_DEFAULT}

setStyleValue() {
  [[ $# = 0 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && exit 1
  if validation::alpha_num "${1}";
  then
    local __style_variable_name="STYLE_$(string::to_upper ${1})"
    local __text_style="$[__style_variable_name]"
  
    if [[ "${__text_style}" == 0 ]];
    then
      if [[ ${__style_variable_name} == "STYLE_NORMAL" ]];
        then
          styleValue=${__text_style}
        else
          printf "The style option is not valid (options: normal, bold, dim, italics, underline, etc)\n"
          exit 1
        fi
      else
        styleValue=${__text_style}
    fi
  else
    printf "The style option is not valid (options: normal, bold, dim, italics, underline, etc)\n"
    exit 1
  fi
}

setTextColorValue() {
  [[ $# = 0 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && exit 1
  if variable::is_int "${1}";
  then
    if [[ "${1}" -ge 0 && "${1}" -le 256 ]];
    then
      textColorValue=${1}
    else
      printf "Color value is not valid (it needs to be an integer between 0 and 256)\n"
      exit 1
    fi
  else
    local __text_color_variable_name="COLOR_$(string::to_upper ${1} | sed -e 's/[\-]/\_/g')"
    local __text_color="$[__text_color_variable_name]"
  
    if [[ "${__text_color}" == 0 ]];
    then
      printf "Color option is not valid (e.g. of valid options: default, black, white, red, light-red)\n"
      exit 1
    else
      textColorValue=${__text_color}
    fi
  fi
}

setBackgroundColorValue() {
  [[ $# = 0 ]] && printf "%s: Missing arguments\n" "${FUNCNAME[0]}" && exit 1
  if variable::is_int "${1}";
  then
    if [[ "${1}" -ge 0 && "${1}" -le 256 ]];
    then
      backgroundColorValue=${1}
    else
      printf "Background color value is not valid (it needs to be an integer between 0 and 256)\n"
      exit 1
    fi
  else
    local __background_color_variable_name="BG_COLOR_$(string::to_upper ${1} | sed -e 's/[\-]/\_/g')"
    local __background_color="$[__background_color_variable_name]"
  
    if [[ "${__background_color}" == 0 ]];
    then
      printf "Background color option is not valid (e.g. of valid options: default, black, white, red, light-red)\n"
      exit 1
    else
      backgroundColorValue=${__background_color}
    fi
  fi
}

styleText() {
  local text=${@: -1}
  while (( $# > 1 ))
  do
    case $1 in
      -s|--style)
        setStyleValue ${2}
        ;;
      -c|--color)
        setTextColorValue ${2}
        ;;
      -b|--background-color)
        setBackgroundColorValue ${2}
        ;;
    esac
    shift
  done

  printf "${text}\n"
  printf "${styleValue}\n"
  printf "${textColorValue}\n"
  printf "${backgroundColorValue}\n"

}


styleText "${@}"