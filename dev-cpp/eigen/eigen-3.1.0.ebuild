# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=4

inherit cmake-utils alternatives-2 fortran-2 multilib

DESCRIPTION="C++ template library for linear algebra"
HOMEPAGE="http://eigen.tuxfamily.org/"

MYPV=${PV/_/-}
SRC_URI="http://bitbucket.org/eigen/eigen/get/${MYPV}.tar.bz2 -> ${P}.tar.bz2"

LICENSE="|| ( LGPL-3 GPL-2 )"
KEYWORDS="~amd64 ~x86 ~amd64-linux ~x86-linux"
SLOT="3"
IUSE="adolc doc fortran fftw gmp mkl sparse static-libs test"

# TODO: support for pastix
CDEPEND="adolc? ( sci-libs/adolc[sparse?] )
	fftw? ( >=sci-libs/fftw-3 )
	gmp? ( dev-libs/gmp dev-libs/mpfr )
	mkl? ( sci-libs/mkl )
	sparse? ( dev-cpp/sparsehash
			sci-libs/cholmod[metis]
			sci-libs/superlu
			sci-libs/umfpack )"

DEPEND="doc? ( app-doc/doxygen[dot,latex] )
	test? ( ${CDEPEND} )"

RDEPEND="!dev-cpp/eigen:0
	${CDEPEND}"

pkg_setup() {
	use fortran && fortran-2_pkg_setup
}

src_unpack() {
	unpack ${A} && mv ${PN}* ${P}
}

src_configure() {
	# TOFIX: static-libs for blas are always built with PIC
	# TOFIX: BTL benchmarks
	# TOFIX: is it worth fixing all the automagic given no library is built?
	mycmakeargs=(
		-DEIGEN_BUILD_BTL=OFF
	)
	CMAKE_BUILD_TYPE="release" cmake-utils_src_configure
	use fortran && FORTRAN_LIBS="blas lapack"
}

src_compile() {
	local targets="${FORTRAN_LIBS}"
	use doc && targets+=" doc"
	cmake-utils_src_compile ${targets}
}

src_install() {
	cmake-utils_src_install
	use doc && dohtml -r "${CMAKE_BUILD_DIR}"/doc/html/*
	local x
	for x in ${FORTRAN_LIBS}; do
		local libname="eigen_${x}"
		cd "${CMAKE_BUILD_DIR}"/${x}
		dolib.so lib${libname}.so
		use static-libs && newlib.a lib${libname}_static.a lib${libname}.a
		cat > ${libname}.pc <<-EOF
			prefix=${EPREFIX}/usr
			libdir=\${prefix}/$(get_libdir)
			includedir=\${prefix}/include
			Name: ${PN}
			Description: ${DESCRIPTION} ${x^^} implementation
			Version: ${PV}
			URL: ${HOMEPAGE}
			Libs: -L\${libdir} -l${libname}
			Libs.private: -lm
			$([[ ${x} == lapack ]] && echo "Requires: blas")
		EOF
		alternatives_for ${x} eigen 0 \
			/usr/$(get_libdir)/pkgconfig/${x}.pc ${libname}.pc
		insinto /usr/$(get_libdir)/pkgconfig
		doins ${libname}.pc
	done
}