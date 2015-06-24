if [ "$OSTYPE[0,7]" = "solaris" ]
then
	if [ ! -x ${HOME}/bin/nroff ]
	then
		mkdir -p ${HOME}/bin
		cat > ${HOME}/bin/nroff <<EOF
#!/bin/sh
if [ -n "\$_NROFF_U" -a "\$1,\$2,\$3" = "-u0,-Tlp,-man" ]; then
	shift
	exec /usr/bin/nroff -u\${_NROFF_U} "\$@"
fi
#-- Some other invocation of nroff
exec /usr/bin/nroff "\$@"
EOF
	chmod +x ${HOME}/bin/nroff
	fi
fi

man() {
      env \
        LESS_TERMCAP_mb=$'\E[01;31m'\
      LESS_TERMCAP_md=$'\E[01;31m'\
      LESS_TERMCAP_me=$'\E[0m'\
      LESS_TERMCAP_se=$'\E[0m'\
      LESS_TERMCAP_so=$'\E[38;5;015m\E[48;5;242m'\
      LESS_TERMCAP_ue=$'\E[0m'\
      LESS_TERMCAP_us=$'\E[01;32m'\
	  PAGER=/usr/bin/less \
	  _NROFF_U=1 \
	  PATH=${HOME}/bin:${PATH} \
	  			   man "$@"
}
