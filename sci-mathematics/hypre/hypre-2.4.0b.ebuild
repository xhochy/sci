# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI=3

inherit eutils

DESCRIPTION="Parallel High Performance Preconditioners library for scalable
solution of linear systems"
HOMEPAGE="http://www.llnl.gov/casc/hypre/"
SRC_URI="http://sourceforge.net/projects/charon-suite/files/thirdparty/${P}.tar.gz"

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="~x86 ~amd64"
IUSE="fortran lapack mpi debug static-libs"

RDEPEND="
	virtual/mpi
	sys-devel/gcc[fortran?]
	lapack? ( virtual/blas virtual/lapack )
"
DEPEND="${RDEPEND}"

S="${WORKDIR}/${P}/src"

src_prepare() {
	epatch "${FILESDIR}/${P}-soname.patch"
}

src_configure() {
	local myconf
	use static-libs \
		&& myconf[0]="--disable-shared" \
		|| myconf[0]="--enable-shared"
	myconf[1]="$(use_enable debug)"
	myconf[2]="$(use_enable fortran)"
	myconf[3]="--disable-python"
	myconf[4]="--disable-java"
	myconf[5]="$(use_with mpi MPI)"
	myconf[6]="$(use_with lapack blas)"
	myconf[7]="$(use_with lapack)"
	myconf[8]="--without-superlu"

	if use lapack; then
		myconf[10]="--with-blas-libs=blas"
		myconf[11]="--with-blas-lib-dirs=/usr/$(get_libdir)"
		myconf[12]="--with-lapack-libs=lapack"
		myconf[13]="--with-lapack-lib-dirs=/usr/$(get_libdir)"
	fi

	econf "${myconf[@]}" || die "configure failed"
}

src_install() {
	if use static-libs; then
		dolib.a  lib/libHYPRE*.a*
	else
		dolib.so lib/libHYPRE*.so*
	fi
	insinto /usr/include/${PN}
	doins -r hypre/include/*
}
