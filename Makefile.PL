use inc::Module::Install;

githubmeta;

name     'MooseX-TrackDirty-Attributes';
all_from 'lib/MooseX/TrackDirty/Attributes.pm';
author   q{Chris Weyl <cweyl@alumni.drew.edu>};
license  'lgpl';

no_index 'directory' => 'xt';

requires 'Moose'                => '0.88';
requires 'namespace::autoclean' => '0.08';

test_requires 'Test::More' => '0.92';

extra_tests;
auto_provides;
auto_install;

WriteAll;

