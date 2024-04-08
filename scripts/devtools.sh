#!/bin/sh

devtools_cpp() {
	apt install -y \
		gcc \
		g++ \
		valgrind \
		gdb \
		clangd \
		autoconf \
		libtool \
		python3-pip

	# Install CMake
	mkdir /home/user/src/cmake
	curl -sSL https://github.com/Kitware/CMake/releases/download/v3.28.1/cmake-3.28.1.tar.gz | tar -xz --strip-components=1 -C /home/user/src/cmake && cd /home/user/src/cmake
	./bootstrap && make && make install

	# Install vpckg
	mkdir /opt/vcpkg
	git clone https://github.com/Microsoft/vcpkg.git /opt/vcpkg
	chown -R user:user /opt/vcpkg
	cd /opt/vcpkg && ./bootstrap-vcpkg.sh -disableMetrics
	ln -s /opt/vcpkg/vcpkg /usr/local/bin/vcpkg
}

devtools_iac() {
	apt install -y \
		ansible \
		vagrant
}
