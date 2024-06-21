# Copy this to /etc/profile.d/ per these instructions (https://www.if-not-true-then-false.com/2018/install-nvidia-cuda-toolkit-on-fedora/#19-post-installation-tasks)

case ":${PATH}:" in
*:"/usr/local/cuda/bin":*) ;;
*)
	PATH=/usr/local/cuda/bin:$PATH
	;;
esac

case ":${LD_LIBRARY_PATH}:" in
*:"/usr/local/cuda/lib64":*) ;;
*)
	if [ -z "${LD_LIBRARY_PATH}" ]; then
		LD_LIBRARY_PATH=/usr/local/cuda/lib64
	else
		LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH
	fi
	;;
esac

HOST_COMPILER='gcc-12 -lstdc++ -lm'

export PATH LD_LIBRARY_PATH HOST_COMPILER
