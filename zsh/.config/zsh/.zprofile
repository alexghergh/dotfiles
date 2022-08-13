# The file .zprofile is basically the same as .zlogin except that it's sourced
# before .zshrc while .zlogin is sourced after .zshrc. According to the zsh
# documentation: ".zprofile is meant as an alternative to .zlogin for ksh
# fans; the two are not intended to be used together, although this could
# certainly be done if desired."
#
# This runs once when the system starts (will be read when starting as a login
# shell).
# To reload: "exec zsh --login"
#
