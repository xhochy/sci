# Copyright 1999-2008 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils

DESCRIPTION="Storm Water Management Model - SWMM, hydrology, hydraulics, and
water quality model."
HOMEPAGE="http://www.epa.gov/ednnrmrl/models/swmm/index.htm"
SRC_URI="http://www.epa.gov/ednnrmrl/models/swmm/epaswmm5_engine.zip
	doc? ( http://www.epa.gov/ednnrmrl/models/swmm/epaswmm5_manual.pdf
	       http://www.epa.gov/ednnrmrl/models/swmm/epaswmm5_updates.txt )"

LICENSE="public-domain"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc"

DEPEND=""
RDEPEND=""

S="${WORKDIR}/${PN}"

src_unpack() {
	mkdir "${S}" && cd "${S}"
	unpack epaswmm5_engine.zip
	# Need to delete Readme.txt, because it is in makefiles.zip
	rm Readme.txt
	unpack ./makefiles.zip
	unpack ./GNU_CON.zip
	unpack ./source.ZIP
}


src_compile(){
	# 'sed' command has to accomodate DOS formatted file.
	sed -i \
	    -e 's;^#define DLL.*$;;' \
		swmm5.c
	emake || die "compile failed"
}


src_install(){
	# Don't like the version number in the name.
	mv swmm5 swmm
	dobin swmm
	if use doc ; then
		dodoc "${DISTDIR}"/epaswmm5_manual.pdf
		dodoc "${DISTDIR}"/epaswmm5_updates.txt
		dodoc Roadmap.txt
	fi
}
