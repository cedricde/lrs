Vendor:       Hans Reiser
Distribution: Hans Reiser
Name:         reiserfsprogs
Release:      1
Copyright:    2001 Hans Reiser
Group:        Unsorted

Packager:     anthon@mnt.org

Version:      3.x.0i
Summary:      utilities belonging to the Reiser filesystem
Source:       reiserfsprogs-%{version}.tar.gz
BuildRoot:    /var/tmp/rpm-reiserfsprogs
%description

The reiserfsprogs package contains programs for creating (mkreiserfs),
checking and correcting any inconsistencies (reiserfsck) and resizing
(resize_reiserfs) of a reiserfs filesystem.

Authors:
--------
Hans Reiser <reiser@namesys.com>
Vitaly Fertman <vetalf@inbox.ru>
Alexander Zarochentcev <zam@namesys.com>
Vladimir Saveliev <vs@namesys.botik.ru>

%prep
%setup -q
# %patch
%build
  MANDIR=$(dirname $(dirname $(man -w fsck | cut -d ' ' -f 1)))
  ./configure --prefix="" --mandir=$MANDIR
  make all
%install
    mkdir -p $RPM_BUILD_ROOT/sbin
    make DESTDIR=$RPM_BUILD_ROOT install
%clean
# in case some overrides buildroot with / don't remove the whole tree
    rm -rf /var/tmp/rpm-reiserfsprogs
%files
/
%doc README



