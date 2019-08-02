# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=7

PYTHON_COMPAT=( python3_{5,6,7} )

inherit flag-o-matic python-single-r1

MY_PN=RetroArch
MY_P=${MY_PN}-${PV}

DESCRIPTION="Frontend for emulators, game engines and media players"
HOMEPAGE="https://www.retroarch.com/"
SRC_URI="https://github.com/libretro/${MY_PN}/releases/download/v1.7.7/${MY_P}.tar.xz"

LICENSE="GPL-3+"
SLOT="0"
KEYWORDS="~amd64 ~x86"

IUSE="alsa cg cpu_flags_x86_sse dbus egl ffmpeg flac freetype gles gles3 kms
	libcaca libusb materialui miniupnpc openal +opengl +ozone pulseaudio
	python qt rgui sdl sdl2 sixel subtitles ssl stripes systemd tinyalsa udev
	vulkan X xrandr xmb xv wayland zlib"

MENU_REQUIRED_USE="|| ( gles opengl vulkan )"
REQUIRED_USE="
	cg? ( opengl )
	gles? ( egl )
	gles3? ( gles )
	kms? ( egl )
	materialui? (
		${MENU_REQUIRED_USE}
	)
	opengl? ( !gles )
	ozone? ( ${MENU_REQUIRED_USE} )
	python? ( ${PYTHON_REQUIRED_USE} )
	rgui? (
		${MENU_REQUIRED_USE}
		|| ( libcaca sdl sdl2 sixel )
	)
	stripes? ( ${MENU_REQUIRED_USE} )
	xmb? ( ${MENU_REQUIRED_USE} )
	sdl? ( !sdl2 )
	xv? ( X )
"

RDEPEND="
	alsa? ( media-libs/alsa-lib )
	cg? ( media-gfx/nvidia-cg-toolkit )
	gles? ( media-libs/mesa:0=[gles2] )
	ffmpeg? ( virtual/ffmpeg )
	flac? ( media-libs/flac )
	freetype? ( media-libs/freetype )
	kms? (
		media-libs/mesa:0=[gbm]
		x11-libs/libdrm
	)
	libcaca? ( media-libs/libcaca )
	libusb? ( virtual/libusb:= )
	miniupnpc? ( net-libs/miniupnpc )
	openal? ( media-libs/openal )
	pulseaudio? ( media-sound/pulseaudio )
	python? ( ${PYTHON_DEPS} )
	qt? (
		dev-libs/openssl:0=
		dev-qt/qtconcurrent:5
		dev-qt/qtcore:5
		dev-qt/qtgui:5
		dev-qt/qtnetwork:5
		dev-qt/qtwidgets:5
	)
	sdl? ( media-libs/libsdl )
	sdl2? ( media-libs/libsdl2 )
	sixel? ( media-libs/libsixel )
	ssl? ( net-libs/mbedtls )
	subtitles? ( media-libs/libass )
	systemd? ( sys-apps/systemd )
	udev? ( virtual/udev )
	vulkan? ( media-libs/vulkan-loader[X?,wayland?] )
	X? (
		x11-libs/libX11
		x11-libs/libXext
		x11-libs/libXxf86vm
		x11-libs/libxcb
	)
	xrandr? ( x11-libs/libXrandr )
	xv? ( x11-libs/libXv )
	wayland? (
		dev-libs/wayland
		dev-libs/wayland-protocols
	)
	zlib? ( sys-libs/zlib )
"
DEPEND="${RDEPEND}
	vulkan? ( dev-util/vulkan-headers )"

S="${WORKDIR}/${MY_P}"

src_prepare() {
	default

	# RetroArch's configure is shell script, not autoconf one
	# However it tryes to mimic autoconf configure options
	sed -i -e \
		's#'') : ;;#''|--infodir=*|--datadir=*|--localstatedir=*|--libdir=*) : ;;#g' \
		qb/qb.params.sh || die
}

src_configure() {
	if use cg; then
		append-ldflags -L/opt/nvidia-cg-toolkit/$(get_libdir)
		append-cppflags -I/opt/nvidia-cg-toolkit/include
	fi

	econf \
		--enable-threads \
		--enable-mmap \
		--enable-networking \
		--enable-zlib \
		--disable-audioio \
		--disable-builtinflac \
		--disable-builtinmbedtls \
		--disable-builtinminiupnpc \
		--disable-coreaudio \
		--disable-jack \
		--disable-mpv \
		--disable-oss \
		--disable-roar \
		--disable-rsound \
		--disable-videocore \
		$(use_enable alsa) \
		$(use_enable cg) \
		$(use_enable cpu_flags_x86_sse sse) \
		$(use_enable dbus) \
		$(use_enable egl) \
		$(use_enable freetype) \
		$(use_enable flac) \
		$(use_enable ffmpeg) \
		$(use_enable gles opengles) \
		$(use_enable gles3 opengles3) \
		$(use_enable libcaca caca) \
		$(use_enable libusb) \
		$(use_enable materialui) \
		$(use_enable miniupnpc) \
		$(use_enable openal al) \
		$(use_enable opengl) \
		$(use_enable ozone) \
		$(use_enable pulseaudio pulse) \
		$(use_enable python) \
		$(use_enable qt) \
		$(use_enable sdl) \
		$(use_enable sdl2) \
		$(use_enable sixel) \
		$(use_enable subtitles ssa) \
		$(use_enable ssl) \
		$(use_enable systemd) \
		$(use_enable tinyalsa) \
		$(use_enable udev) \
		$(use_enable vulkan) \
		$(use_enable wayland) \
		$(use_enable X x11) \
		$(use_enable xrandr) \
		$(use_enable xv xvideo) \
		$(use_enable zlib)
}
